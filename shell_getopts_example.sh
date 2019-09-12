#!/bin/bash

while getopts ':f:u:' option
do
case $option in
  f) file=$OPTARG
     echo "file name is $file"
   ;;
  u) user=$OPTARG
     echo "User name is $user"
    ;;
  ?) echo "invalid args"
     echo "usage: $0 -f <filename> -u <username>"
    ;;
esac
done
