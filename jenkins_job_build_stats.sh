#!/bin/bash
#Script to collect the stat of jenkins jobs building per day per service

SERVICES=("etl" "ges" "api" "ui" "conexus" "adapter" "sei" "proxy" "tests" "ondemand" "chronization" "buffer" "processor")
DIR="/jenkins/workspace"
LOG_FILE="/tmp/jenkins_stat.txt"
RECIPIENTS="subham.jack2011@gmail.com"


echo -e "SERVICE_NAME\tNUMBEROF_BUILDS\tSPACE_OCCUPIED" > ${LOG_FILE}
echo -e "------------\t----------------\t--------------" >> ${LOG_FILE}
for SERVICE in ${SERVICES[@]}
do
#find . -mtime 1 # find files modified between 24 and 48 hours ago
NUM_OF_BUILDS="$(find $DIR  -maxdepth 1 -mtime 1 |grep $SERVICE |grep -v tmp$|awk '{print $NF}'|wc -l)"
if [ "${NUM_OF_BUILDS}" -ne "0" ];then
   SPACE="$(find $DIR  -maxdepth 1 -mtime 1 |grep $SERVICE |grep -v tmp$|awk '{print $NF}'|xargs du -csh|grep total|awk '{print $1}')"
   echo -e "${SERVICE}\t${NUM_OF_BUILDS}\t${SPACE}"
fi
done >> ${LOG_FILE}

[ -f ${LOG_FILE} ] && cat ${LOG_FILE} |column -t > /tmp/jenkins_stat_tmp.txt && rm -f ${LOG_FILE} && mv /tmp/jenkins_stat_tmp.txt ${LOG_FILE}
if [ $(cat ${LOG_FILE} |wc -l) -gt 2 ];then
mailx -s "$(hostname): Jenkins Build Stats" -S "from=subham.jack2011@gmail.com" "${RECIPIENTS}"  < ${LOG_FILE}|column -t
fi

rm -f ${LOG_FILE}
