#!/usr/bin/env bash

shopt -s xpg_echo

function clean (){
rm -rf $LOG_FILE $TEMP_FILE
}

function color() {
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)
}

trap clean EXIT INT TERM HUP KILL QUIT

LOG_FILE=$(mktemp)
TEMP_FILE=$(mktemp)
CMD="multipath -ll"

color

if ! command -v ${CMD} &> /dev/null;then
   echo "${red}\"$CMD\" command could not be found in this server \"$(hostname)\"${reset}"
elif command -v ${CMD} &> /dev/null && [[ $(ps -ef|grep multipathd|grep -v grep|wc -l) -lt 1 ]];then
   echo "${red}Multipath installed - but not configured in this server \"$(hostname)\" - Please configure and start the service${reset}"
else
   sudo ${CMD} > $LOG_FILE
   if [[ -s $LOG_FILE ]];then
      echo "${green}Please find LUN details as follows in this server \"$(hostname)\"${reset}"
      cat file |awk 'NR>1 {r=f=0;for (i=1;i<=NF;i++) if ($i~/ready/) r++; else if ($i~/faulty/) f++;split($5,a,"=|]");print $1"\tTotal: "r+f" paths, active: "r,"failed: "f}' RS="mpath" OFS=", "  > $TEMP_FILE
      cat $TEMP_FILE |awk -v name=mpath -F',' '{new_var=name$1;print new_var $2 $3 $4}' > $TEMP_FILE_$$ && mv  $TEMP_FILE_$$  $TEMP_FILE && cat $TEMP_FILE
   fi
fi
