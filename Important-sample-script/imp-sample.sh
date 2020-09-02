#!/bin/bash

FILE="/tmp/log"

function change_alert() {

local LINE="$1"
E1="$(echo $LINE|cut -d'-' -f2-3)"
E2="$(echo $LINE|cut -d'-' -f1)"
E1+=" $E2"
echo $E1
}

LINE1=$(change_alert "$(tail -n2 $FILE|head -1)")
LINE2=$(change_alert "$(tail -n1 $FILE)")
tac $FILE|sed '1,2d'|tac > file.tmp && echo "$LINE1" >>  file.tmp && echo "$LINE2" >>  file.tmp && rm -f $FILE && mv file.tmp $FILE



#!/bin/bash

FILE="/home/subham/.profile"

LINK_PATH_FIRST="/link/file1"
LINK_PATH_SECOND="/link/file2"


if [[ -L "$FILE" ]];then
echo "$FILE is a link file to $(readlink $FILE) file"
     if [[ "$(readlink $FILE)" == "$LINK_PATH_FIRST" ]];then
     :
     else
     unlink $FILE && sleep 1
     ln -sf $LINK_PATH_FIRST .profile
     echo "$FILE link has been updated with $(readlink $FILE) file"
     fi
else
echo "$FILE does not exits,creating $FILE"
ln -sf $LINK_PATH_FIRST .profile
fi



#!/bin/bash

shopt -s xpg_echo

SCRIPT_NAME="link.sh"

CRON_ENTRY=$(crontab -l|grep "$SCRIPT_NAME")

if [[ -z "$CRON_ENTRY" ]];then
echo "Cron entry not present on host: $(hostname)"
else
  if [[ ${CRON_ENTRY:0:1} == '#' ]];then
     echo "Cron entry is commented on hosts: $(hostname), uncommenting it"
     echo "$(crontab -l|grep -v $SCRIPT_NAME )\n${CRON_ENTRY/##/}" | crontab -
     fi
fi
