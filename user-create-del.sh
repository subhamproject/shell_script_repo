#!/bin/bash
user_add () {
 while [ -z "${USERNAME}" ];do
 echo -e "Please enter username you wish to add?:- \c"
 read  USERNAME
 [ -z "${USERNAME}" ] && echo "Username Cannot be empty,Please try again."
done
 grep -q $USERNAME /etc/passwd >> /dev/null
 if [ $? -eq 0 ];then
  echo "User $USERNAME already exist"
else
  useradd $USERNAME  && echo "User $USERNAME has been created" && echo -e "Please enter the password to set?:- \c"
  read PASSWORD
  echo "$USERNAME:$PASSWORD" |chpasswd  > /dev/null
  [ $? -eq 0 ] && echo "Password has been set for user $USERNAME"
fi
unset USERNAME
}

user_del () {
 while [ -z "${USER_NAME}" ];do
 echo -e "Please enter the user name you wish to delete?:- \c"
 read USER_NAME
 [ -z "${USER_NAME}" ] && echo "Username Cannot be empty,Please try again."
done
 grep -q $USER_NAME /etc/passwd >> /dev/null
 if [ $? -eq 0 ] ;then
   echo -e "User $USER_NAME exist,Are you sure to proceed with deletion(yes/no)?:- \c"
   read RES
   [ "${RES}" == "Y" -o "${RES}" == "y" -o "${RES}" == "yes" -o "${RES}" == "YES" ] && userdel -r $USER_NAME > /dev/null 2>&1 && echo "User $USER_NAME has been deleted successfully"
   [ "${RES}" == "N" -o "${RES}" == "n" -o "${RES}" == "no" -o "${RES}" == "NO" ] && echo "You have chosen not to delete $USER_NAME..Skipping"
 else
   echo "User does not exist"
 fi
unset USER_NAME
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
