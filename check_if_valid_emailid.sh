https://stackoverflow.com/questions/48014738/how-to-validate-email-id-using-bash-script

#!/bin/sh
while true; do
read -p "Enter Email ID: " to_recipient
if [[ "$to_recipient" =~ [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4} ]]
then
    break;
else
    echo "Please enter a valid email address"
fi
done

#!/bin/bash

while ! [[ "$image" =~ ^(rhel74|rhel75|cirros35)$ ]] 
do
  echo "Which image do you want to use: rhel74 / rhel75 / cirros35 ?"
  read -r image
done 



if ! [[ "$number1" =~ ^[+-]?[0-9]+\.?[0-9]*$ ]] || ! [[ "$number2" =~ ^[+-]?[0-9]+\.?[0-9]*$ ]] 
then 
    echo "Inputs must be a numbers" 
    exit 0 
fi



i="test@terraes"
IFS="@"
set -- $i
if [ "${#@}" -ne 2 ];then
    echo "invalid email"
fi
domain="$2"
dig $domain | grep "ANSWER: 0" 1>/dev/null && echo "domain not ok"
