#!/bin/bash

## Pass the dirname as argument to this script
[ $# -ne 1 ] && echo "Usage: $0 <dirname>" && exit 1

DIR_NAME=${1}

FILES="$(find ${DIR_NAME} ! -empty -type f -exec md5sum {} + | sort | uniq -w32 -dD|while read FILE_SHA FILE_NAME
do
echo
echo $FILE_SHA
echo $FILE_NAME
done |awk '!_[$0]++')"  && \
[ -n "${FILES}" ] && \
echo -e "Please find the identical files given path ${DIR_NAME}\nFiles listed underneath each sha value are identical having same content" && echo&& \
echo $FILES |tr ' ' '\n' || echo "No identical files found in path ${DIR_NAME}"
