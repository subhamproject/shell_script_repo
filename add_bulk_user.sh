#!/bin/bash
# Script to add, delete, assign password to multiple users in linux

IFS=$'\n'
declare -A name_pass

TEMP1="/tmp/file1.log"
TEMP2="/tmp/file2.log"
TEMP3="/tmp/file3.log"

function delete_temp() {
rm -rf $TEMP1 $TEMP2 $TEMP3 || true
}

function usage(){
  echo "Usage: $0 -u|--user   -p|--password"
  echo "-u|--user:     Provide Username To Add"
  echo "-p|--password  Provide password to Assign to User"
  echo "-d|--delete    Provide Username to Delete"
  exit 1
}

[ $# -lt 1 ] && usage || true
[ $(id -u) -eq 0 ] || { echo "$0: Only root may add a user or group to the system."; exit 1;}

trap delete_temp EXIT

function add_user() {
local NAME=$1
local user=""
for user in $NAME;do
if ! getent passwd $user > /dev/null 2>&1; then
useradd -m -d /home/$user -s /bin/bash $user || { echo "$0: User \"$user\" addition failed."; }
else
echo "The user '$user' already exits."
fi
done
}

function delete_user() {
local NAME=$1
local user=""
for user in $NAME;do
if getent passwd $user > /dev/null 2>&1; then
[ -d /home/$user ] && rm -rf /home/$user || true
userdel $user
else
echo "User  \"$user\" does not exist"
fi
done
}


function assign_password(){
local user_pass=$1
echo "$user_pass:${name_pass[$user_pass]}" |sudo chpasswd || { echo "$0: Failed to set password for the $user_pass."; }
}

#Parsing Args
while [[ $1 ]];do
 case $1 in
   -u | --user)
          NAME=$2
          shift
    ;;
   -p | --password)
          PASS=$2
          shift
    ;;
  -d | --delete)
         DEL=$2
         shift
    ;;
esac
shift
done

[ -n "$NAME" ] && echo $NAME > $TEMP1 || true
[ -n "$PASS" ] && echo $PASS > $TEMP2 || true
[ -n "$DEL" ] && echo $DEL >  $TEMP3  || true

function user_pass_mapping() {
id=$1
pass=$2
local i=""
while read line
do
for i in $line
do
eval name_pass$(echo $i|awk -F' ' '{print "["$1"]""="$2}')
done
done < <(paste <(cat $id|tr ',' '\n') <(cat $pass|tr ',' '\n'))
}

function main(){
SCRIPT=$1
FILE=$2
while read line
do
for LINE in $line
do
$SCRIPT $LINE
done
done < <(cat $FILE|tr ',' '\n')
}

[ -s $TEMP1 ] && main add_user  $TEMP1 || :
[ -s $TEMP3 ] && main delete_user $TEMP3 || :
[ -s $TEMP1 ] && [ -s $TEMP2 ] && user_pass_mapping $TEMP1 $TEMP2 && \
for key in "${!name_pass[@]}";do
assign_password $key
done || true
