#!/bin/bash

shopt -s xpg_echo

function usage(){
  echo "Usage: $0 -s|--service -a|--adhoc -v|--version -d|--dryrun
        -s|--service:   Please provide core service name(Default:-all)!
        -a|--adhoc:     Please provide adhoc service names(Comma seperated)!
        -v|--version:   Please provide the latest version you wish to set!
        -d|--dryrun:    Enable dryrun,Don't execute command!"
  exit 1
}

[ $# -lt 1 ] && usage || true

FILE="core_image_list.txt"

function dryrun() {
    printf -v cmd_str '%q ' "$@"; echo "DRYRUN: Not executing:-> $cmd_str" >&2
}

function update_version() {
image=$1
CURRENT=$(echo $image|awk -F'-' '{print $NF}')
IMAGE=$(echo $image|sed "s|$CURRENT|$VERSION|")
}

function change() {
line=$1
service=$2
update_version $line
[ -n "${OPTION}" ] && dryrun $(echo "Changing image for: $service") || echo "Changing image for: $service"
[ -n "${OPTION}" ] && dryrun $(echo "Image name is: $IMAGE") || echo "Image name is: $IMAGE"
[ -n "${OPTION}" ] && dryrun $(echo "rcx service alter --image $IMAGE $service") || rcx service alter --image $IMAGE $service
}

#Parsing Args
while [[ $1 ]];do
 case $1 in
   -s|--service)
          SERVICE=$2
          shift
    ;;
   -a|--adhoc)
          ADHOC=$2
          shift
    ;;
   -v|--version)
          VERSION=$2
          shift
    ;;
  -d|--dryrun)
          OPTION=true
          shift
    ;;
esac
shift
done


function alter_image(){
while read line
do
service=$(echo $line|cut -d':' -f2|sed 's|master-||g'|cut -d'.' -f1|sed 's|-1||g')
change $line $service
done < $FILE
}

case $SERVICE in
all)
alter_image
 ;;
esac


function adhoc(){
while read line
do
for i in $line
do
if [ "$i" == "crud-ui" ];then
i=crud
LINE=$(grep -w $i $FILE)
[ -n "$LINE" ] && service=$(echo $LINE|cut -d':' -f2|sed 's|master-||g'|cut -d'.' -f1|sed 's|-1||g')
service=crud-ui
else
LINE=$(grep -w $i $FILE)
[ -n "$LINE" ] && service=$(echo $LINE|cut -d':' -f2|sed 's|master-||g'|cut -d'.' -f1|sed 's|-1||g')
fi
change $LINE $service
done
done < <(echo ${ADHOC//,/\\n})
}

[ -n "$ADHOC" ] && adhoc
