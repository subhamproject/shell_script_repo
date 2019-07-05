#!/bin/bash
DIR=$(dirname $0)
count=0
error=0
duplicate=0
cd $DIR/incoming
FILES=$(ls)
for file in $FILES
do
  if [[ -f ../archive/$file ]] && [[ $(stat -c%s $file) -eq $(stat -c%s ../archive/$file)  ]] && \
     [[ $(md5sum $file |cut -d' ' -f1) == $(md5sum ../archive/$file|cut -d' ' -f1) ]] ;then
        echo "File status for \"$file\" match in archive and incoming..Moving to archive with tag duplicate"
        mv $file ../archive/$file.$(date +%s).duplicate && let duplicate=duplicate+1
    else
       cp -pr $file ../s3
       [ $? -eq 0 ] && mv "$file" ../archive && let count=count+1 || let error=error+1
   fi
done
echo "$count file copied,error $error error occured,$duplicate file moved to archive with duplicate tag."
