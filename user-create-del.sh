#!/bin/bash
##### Script to create ,delete, lock ,unlock and reset password for user,adding user to secondary group!

## Generic function for all
check () {
 while [ -z "${USERNAME}" ];do
 echo -e "Please enter the user name: \c"
 read USERNAME
 [ -z "${USERNAME}" ] && echo "Username cannot be empty,Please try again."
 done
}

## Function to add new user
user_add () {
 unset USERNAME
 check
 if [ -n "$(compgen  -u|grep -w $USERNAME)" ];then
   echo "User \"$USERNAME\" already exist"
 else
   useradd $USERNAME  && echo "User \"$USERNAME\" has been created"
   while [ -z "${PASSWORD}" ];do
   echo -e "Please enter the password to set: \c"
   read -s PASSWORD
   [ -z "${PASSWORD}" ] && echo -e "\nPassword cannot be empty,Please try again."
   done
   echo "$USERNAME:$PASSWORD" |chpasswd  > /dev/null
   [ $? -eq 0 ] && echo -e "\nPassword has been set for user \"$USERNAME\""
 fi
unset USERNAME
unset PASSWORD
}

## Function to delete existing user
user_del () {
 unset USERNAME
 check
 if [ -n "$(compgen  -u|grep -w $USERNAME)" ] ;then
   echo -e "User \"$USERNAME\" exist,Are you sure to proceed with deletion(yes/no): \c"
   read RES
   case $RES in
     Y|YES|y|yes)
     userdel -r $USERNAME > /dev/null 2>&1 && echo "User \"$USERNAME\" has been deleted successfully"
    ;;
    N|NO|no|n)
     echo "You have chosen not to delete \"$USERNAME\"..Skipping!"
  ;;
  esac
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
  if [ -n "$(compgen  -u|grep -w $USERNAME)" ];then
   echo -e "User  \"$USERNAME\" exist,Are you sure to proceed with (lock/unlock) user account(yes/no): \c"
   read RES
   case $RES in
     Y|YES|y|yes)
     passwd -$VAL $USERNAME > /dev/null 2>&1
     [ -n "$(uname -a|grep -i linux)" -a -n "$(passwd -S $USERNAME|grep locked)" -a "$VAL" == "l" ] && echo "Account \"$USERNAME\" has been locked"
     [ -n "$(uname -a|grep -i linux)" -a -n "$(passwd -S $USERNAME|grep set)" -a "$VAL" == "u" ] && echo "Account \"$USERNAME\" has been unlocked"
     [ -n "$(uname -a|grep -i ubuntu)" -a "$(passwd -S $USERNAME|cut -d' ' -f2)" == "L" -a "$VAL" == "l" ] && echo "Account \"$USERNAME\" has been locked"
     [ -n "$(uname -a|grep -i ubuntu)" -a "$(passwd -S $USERNAME|cut -d' ' -f2)" == "P" -a "$VAL" == "u" ] && echo "Account \"$USERNAME\" has been unlocked"
     ;;
     N|NO|no|n)
      echo "You have chosen not to (lock/unlock) \"$USERNAME\"..Skipping!"
   ;;
 esac
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
  if [ -n "$(compgen  -u|grep -w $USERNAME)" ];then
   echo -e "User \"$USERNAME\" exist,Are you sure you want reset password(yes/no): \c"
   read RES
   case $RES in
     Y|YES|y|yes)
   while [ -z "${PASSWORD}" ];do
   echo -e "Please enter the password to set: \c"
   read -s PASSWORD
   [ -z "${PASSWORD}" ] && echo -e "\nPassword cannot be empty,Please try again."
   done
   echo "$USERNAME:$PASSWORD" |chpasswd  > /dev/null && echo -e "\nPassword has been reset for user \"$USERNAME\""
    ;;
   N|NO|no|n)
     echo "Not resetting password"
    ;;
esac
else
echo "User does not exist"
fi
unset USERNAME
unset RES
unset PASSWORD
}

## Function to add user to secondary group
add_to_group () {
unset USERNAME
check
  echo -e "Please choose group you want user to add: \c"
  echo " "
  choices=("qa" "dev" "prodsupport" "data" "devops" "Quit")
select choice in "${choices[@]}"
do
  case $choice in
   "qa")
    usermod -aG $choice $USERNAME
    [ $? -eq 0 ] && echo "User \"$USERNAME\" has been added to \"$choice\" group."
    ;;
  "dev")
   usermod -aG $choice $USERNAME
   [ $? -eq 0 ] && echo "User \"$USERNAME\" has been added to \"$choice\" group."
     ;;
  "prodsupport")
   usermod -aG $choice $USERNAME
   [ $? -eq 0 ] && echo "User \"$USERNAME\" has been added to \"$choice\" group."
    ;;
 "data")
  usermod -aG $choice $USERNAME
  [ $? -eq 0 ] && echo "User \"$USERNAME\" has been added to \"$choice\" group."
   ;;
 "devops")
  usermod -aG $choice $USERNAME
  [ $? -eq 0 ] && echo "User \"$USERNAME\" has been added to \"$choice\" group."
  ;;
 "Quit")
  break ;
    ;;
 *) echo "invalid option $REPLY";;
 esac
 break
 done
unset USERNAME
}

## Function to create new group
create_group () {
while [ -z "${GROUP}" ];do
  echo -e "Please enter group name you wish to create: \c"
  read GROUP
  [ -z "${GROUP}" ] && echo "Groupname Cannot be empty,Please try again."
  done
  groupadd $GROUP
 [ $? -eq 0 ] && echo "Group \"$GROUP\" has been created"
unset GROUP
}


## Main execution of all function
PS3='Please select your choice: '
options=("Add User" "Delete User" "Lock User" "Unlock User" "Reset Password" "Add User To Group" "Create Group" "Quit")
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
       "Add User To Group")
           add_to_group
            ;;
       "Create Group")
           create_group
            ;;
        "Quit")
            break
            ;;
             *) echo "invalid option $REPLY";;
    esac
done
