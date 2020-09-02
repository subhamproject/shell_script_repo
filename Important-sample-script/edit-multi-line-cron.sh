#!/bin/bash

IFS=$'\n'
shopt -s xpg_echo

SCRIPT_NAME="link.sh"

function edit_cron() {
CRON="$1"
if [[ -z "$CRON" ]];then
:
else
  if [[ ${CRON:0:1} == '#' ]];then
     echo "Cron entry \"$CRON\" is commented on hosts: $(hostname), uncommenting it"
     echo "$(crontab -l|grep -v ${CRON##*/} )\n${CRON/##/}" | crontab -
     else
     echo "Crons \"$CRON\" is not commented on $(hostname)"
     fi
fi
}


CRON_ENTRY=$(crontab -l|grep -E "$SCRIPT_NAME")

set -- $CRON_ENTRY
for cron in "$@"
do
edit_cron "$cron"
done
