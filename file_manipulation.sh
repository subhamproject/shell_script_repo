#!/bin/bash

OLD_IFS=$IFS

IFS=$'\n'
shopt -s xpg_echo

FILE="${1:-file.txt}"

c1=''
c2=''
c3=''
c4=''
c5=''

[ ! -f ${FILE} ] && { echo "$FILE file not found!" ; exit 1 ;} || :

for line in $(cat $FILE);do
LINE1=$(echo $line|awk -F' ' '{print $1}')
LINE2=$(echo $line|awk -F' ' '{print $2}')
LINE3=$(echo $line|awk -F' ' '{print $3}')
LINE4=$(echo $line|awk -F' ' '{print $4}')
LINE5=$(echo $line|awk -F' ' '{print $5}')
if [[ $LINE1 -eq 1 ]];then
c1=1
elif [[ $LINE2 -eq 1 ]];then
c2=1
elif [[ $LINE3 -eq 1 ]];then
c3=1
elif [[ $LINE4 -eq 1 ]];then
c4=1
elif [[ $LINE5 -eq 1 ]];then
c5=1
fi
done
echo "c1\tc2\tc3\tc4\tc5"
echo "$c1\t$c2\t$c3\t$c4\t$c5"

IFS=$OLD_IFS
