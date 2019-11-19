#!/bin/bash

LIMIT=50
EMAIL_FILE="/tmp/send_CPU_email_once.txt"
LOG_FILE="/tmp/cpu_util.txt"


function CPU_ALERT() {
CPU_USAGE=$(top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.0f\n", prefix, 100 - v }')

if [[ ${CPU_USAGE} -gt ${LIMIT} ]];then
    echo "CPU Utilization Threshold Crossed  \"(${CPU_USAGE}%)\" ." >>  ${LOG_FILE}
elif [[ "${CPU_USAGE}" -lt "${LIMIT}" ]] ;then
    [ -f ${EMAIL_FILE} ] && rm ${EMAIL_FILE}
fi
}

CPU_ALERT
[ -s ${LOG_FILE} ] && [ ! -f ${EMAIL_FILE} ] && \
cat ${LOG_FILE} && touch ${EMAIL_FILE}
rm -rf ${LOG_FILE}
