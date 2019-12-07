#The following example, add a user to the Linux system by updating /etc/passwd file and creating home directory at /home for user. It traps various single to avoid errors while creating user accounts. If user pressed CTRL+C or script terminated it will try to rollback changes made to system files. Traps are turned on before the useradd command in shell script, and then turn off the trap after the chpasswd line.

#!/bin/bash
# setupaccounts.sh: A Shell script to add user to the Linux system.
# set path to binary files
ADD=/usr/sbin/useradd
SETPASSWORD=/usr/sbin/chpasswd
USERDEL=/usr/sbin/userdel
# set variables 
HOMEBASE=/home
HOMEDIR=""
username=""

# define function to clean up useradd procedure 
# handle errors using this function
clean_up_useradd(){
    # remove dir
	[ -d $HOMEDIR ]  && /bin/rm -rf $HOMEDIR
	# remove user from passwd if exits
	grep -q "^${username}" /etc/passwd && $USERDEL ${username}
	# now exit
	exit
}

# make sure script is run by root else die 
[ $(id -u) -eq 0 ] || { echo "$0: Only root may add a user or group to the system."; exit 1;}

# get username and password 
read -p "Enter user name : " username

# create homedir path
HOMEDIR="${HOMEBASE}/${username}"

# capture 0 2 3 15 signals
# if script failed while adding user make sure we clean up mess from 
# /home directory and /etc/passwd file
# catch signals using clean_up_useradd()
trap 'clean_up_useradd' SIGINT SIGQUIT SIGTERM

# get password
read -sp "Enter user password : " password 

# make sure user doesn't exits else die
grep -q "^${username}" /etc/passwd && { echo "$0: The user '$username' already exits."; exit 2;}


# create a home dir
echo "Creating home directory for ${username} at ${HOMEDIR}..."
[ ! -d ${HOMEDIR} ] && mkdir -p ${HOMEDIR}

# Add user
echo "Adding user ${username}..."
${ADD} -s /bin/bash -d ${HOMEDIR} ${username} || { echo "$0: User addition failed."; exit 3; }


# Set a password
echo "Setting up the password for ${username}..."
#printf "%s|%s\n" $username $password | ${SETPASSWORD} || { echo "$0: Failed to set password for the user."; exit 3; }
echo "$username:$password" | ${SETPASSWORD} || { echo "$0: Failed to set password for the user."; exit 3; }

# reset all traps 
trap - 0 SIGINT SIGQUIT SIGTERM
