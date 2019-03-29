#!/bin/bash
##### Script to create ,delete, lock ,unlock and reset password for user!

## Generic function for all
check () {
 while [ -z "${USERNAME}" ];do
 echo -e "Please enter the user name: \c"
 read USERNAME
 [ -z "${USERNAME}" ] && echo "Username Cannot be empty,Please try again."
 done
}

## Function to add new user
user_add () {
 unset USERNAME
 check
 if [ -n "$(compgen  -u|grep $USERNAME)" ];then
   echo "User $USERNAME already exist"
 else
   useradd $USERNAME  && echo "User $USERNAME has been created" && echo -e "Please enter the password to set: \c"
   read -s PASSWORD
   echo "$USERNAME:$PASSWORD" |chpasswd  > /dev/null
   [ $? -eq 0 ] && echo -e "\nPassword has been set for user $USERNAME"
 fi
unset USERNAME
unset PASSWORD
}

## Function to delete existing user
user_del () {
 unset USERNAME
 check
 if [ -n "$(compgen  -u|grep $USERNAME)" ] ;then
   echo -e "User $USERNAME exist,Are you sure to proceed with deletion(yes/no): \c"
   read RES
   [ "${RES}" == "Y" -o "${RES}" == "y" -o "${RES}" == "yes" -o "${RES}" == "YES" ] && userdel -r $USERNAME > /dev/null 2>&1 && echo "User $USERNAME has been deleted successfully"
   [ "${RES}" == "N" -o "${RES}" == "n" -o "${RES}" == "no" -o "${RES}" == "NO" ] && echo "You have chosen not to delete $USERNAME..Skipping!"
 else
   echo "User does not exist"
 fi
unset USERNAME
unset RES
}

## Function to lock & unlock existing user
lock_unlock_account () {
 VAL=$1
 unset USERNAME
 check
  if [ -n "$(compgen  -u|grep $USERNAME)" ];then
   echo -e "Are you sure to proceed with (lock/unlock) user account(yes/no): \c"
   read RES
   [ "${RES}" == "Y" -o "${RES}" == "y" -o "${RES}" == "yes" -o "${RES}" == "YES" ]  && passwd -$VAL $USERNAME > /dev/null 2>&1
   [ -n "$(uname -a|grep -i linux)" -a -n "$(passwd -S $USERNAME|grep locked)" -a "$VAL" == "l" ] && echo "Account $USERNAME has been locked"
   [ -n "$(uname -a|grep -i linux)" -a -n "$(passwd -S $USERNAME|grep set)" -a "$VAL" == "u" ] && echo "Account $USEERNAME has been unlocked"
   [ -n "$(uname -a|grep -i ubuntu)" -a "$(passwd -S $USERNAME|cut -d' ' -f2)" == "L" -a "$VAL" == "l" ] && echo "Account $USERNAME has been locked"
   [ -n "$(uname -a|grep -i ubuntu)" -a "$(passwd -S $USERNAME|cut -d' ' -f2)" == "P" -a "$VAL" == "u" ] && echo "Account $USEERNAME has been unlocked"
   [ "${RES}" == "N" -o "${RES}" == "n" -o "${RES}" == "no" -o "${RES}" == "NO" ] && echo "You have chosen not to (lock/unlock) $USERNAME..Skipping!"
else
 echo "User does not exist"
fi
unset USERNAME
unset RES
}

## Function to reset password for existing user
reset_pass () {
 unset USERNAME
 check
  if [ -n "$(compgen  -u|grep $USERNAME)" ];then
   echo -e "User $USERNAME exist,Are you sure you want reset password(yes/no): \c"
   read RES
   [ "${RES}" == "Y" -o "${RES}" == "y" -o "${RES}" == "yes" -o "${RES}" == "YES" ] && echo -e "Please enter the password to set: \c" && read -s PASSWORD && echo "$USERNAME:$PASSWORD" |chpasswd  > /dev/null && echo -e "\nPassword has been reset for user $USERNAME"
  [ "${RES}" == "N" -o "${RES}" == "n" -o "${RES}" == "no" -o "${RES}" == "NO" ] && echo "Not resetting password"
else
echo "User does not exist"
fi
unset USERNAME
unset RES
unset PASSWORD
}

## Main execution of all function
PS3='Please select your choice: '
options=("Add User" "Delete User" "Lock User" "Unlock User" "Reset Password" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Add User")
            user_add
            ;;
        "Delete User")
            user_del
            ;;
        "Lock User")
            lock_unlock_account l
            ;;
        "Unlock User")
            lock_unlock_account u
            ;;
        "Reset Password")
            reset_pass
            ;;
        "Quit")
            break
            ;;
             *) echo "invalid option $REPLY";;
    esac
done
