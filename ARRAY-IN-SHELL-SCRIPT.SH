#!/usr/bin/env bash

declare -A USER_MAP

while read LINES
do
NAME=$(echo $LINES|awk -F':' '{print $1}')
ID=$(echo $LINES|awk -F':' '{print $4}')
USER_MAP+=([$NAME]=$ID)
done < /etc/passwd

for key in "${!USER_MAP[@]}"
do
echo "$key: ${USER_MAP[$key]}"
done
