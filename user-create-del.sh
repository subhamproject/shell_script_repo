#!/bin/bash                                                                                                                                          
user_add () {
 echo -e "Please enter username you wish to add?:- \c"
 read USERNAME
 grep -q $USERNAME /etc/passwd >> /dev/null
 if [ $? -eq 0 ];then
  echo "User $USERNAME already exist"
else
  useradd $USERNAME  && echo "User $USERNAME has been created" && echo -e "Please enter the password to set?:- \c"
  read PASSWORD
  echo "$USERNAME:$PASSWORD" |chpasswd  > /dev/null
  [ $? -eq 0 ] && echo "Password has been set for user $USERNAME"
fi
}
                                                                                                                                                     
user_del () {
 echo -e "Please enter the user name you wish to delete?:- \c"
 read USERNAME
 grep -q $USERNAME /etc/passwd >> /dev/null
 if [ $? -eq 0 ] ;then
   echo -e "User $USERNAME exist,Are you sure to proceed with deletion(yes/no)?:- \c"
   read RES
   [ "${RES}" == "Y" -o "${RES}" == "y" -o "${RES}" == "yes" -o "${RES}" == "YES" ] && userdel -r $USERNAME > /dev/null 2>&1 && echo "User $USERNAME deleted successfully"
   [ "${RES}" == "N" -o "${RES}" == "n" -o "${RES}" == "no" -o "${RES}" == "NO" ] && echo "You have chosen not to delete..Skipping"
 else
   echo "User does not exist"
 fi
}                                                                                                                                                    
PS3='Please select your choice: '
options=("Add User" "Delete User" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Add User")
            user_add
            ;;
        "Delete User")
            user_del
            ;;
        "Quit")
            break
            ;;
             *) echo "invalid option $REPLY";;
    esac
done
