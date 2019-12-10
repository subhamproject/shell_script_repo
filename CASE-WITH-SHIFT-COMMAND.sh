#!/bin/bash

while [[ $1 ]];do
  case $1 in
    -f | --file)
       FILE=$2
       shift
      ;;
   -n | --name)
       NAME=$2
       shift
      ;;
   -p | --password)
       PASS=$2
        shift
     ;;
  esac
 shift
done

echo "You have enter file name \"$FILE\",your name as \"$NAME\" and Password as \"$PASS\""
~
