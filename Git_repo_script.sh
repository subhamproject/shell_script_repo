#!/bin/bash -xe

TEMP_DIR="$(pwd)/tmp"
TEMP_FILE="SBI/service-manifest.txt"
[ -d $TEMP_DIR ] || mkdir -p $TEMP_DIR
if [ $(git diff --name-status HEAD~1 HEAD|grep -v ^D|wc -l) -gt 0 ];then
 FILES=$(git diff --name-status HEAD~1 HEAD|grep -v ^D|awk '{print $2}'|xargs -n1 basename) 2>/dev/null
 echo $FILES > $TEMP_FILE
  for I in $(cat "${TEMP_FILE}"|xargs -n1 basename)
  do
  file=$(find . -name $I)
    if [ -n "${file}" ]
    then
    echo "File \"${file}\" found,Copying to temp dir $TEMP_DIR!"
    cp -pr $file $TEMP_DIR
    fi
 done
 else
 echo "No Changes were done in last commit!" && exit 1
fi
 cd $TEMP_DIR
  [ `ls -1|wc -l` -ge 1 ] &&  tar -zcvf /tmp/archive-name.tar.gz .  >> /dev/null && cd - >> /dev/null
  [ $? -eq 0 ] && cp -pr /tmp/archive-name.tar.gz . >> /dev/null

cat /dev/null > $TEMP_FILE
rm -rf $TEMP_DIR
rm -rf $TEMP_FILE
