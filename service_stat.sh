#!/bin/bash

#TOPIC_ARN="arn:aws:"

TOPIC_ARN="arn:aws"

function service_stat()
{
  local SERVICE_NAME="${1}"
  local FILE="${2:-/tmp/${SERVICE_NAME}_status.txt}"
  local HOSTNAME="${3:-$(hostname)}"
  COUNT=$(ps aux|grep $SERVICE_NAME|grep -v grep|wc -l)
  [ "$SERVICE_NAME" == "rabbitmq_server" ] && local SERVICE_NAME="Rabbitmq"

  if [ "${COUNT}" -le "0" ]
  then
    echo "BACKEND: Prod" > $FILE
    echo "Service: $SERVICE_NAME" >> $FILE
    echo "Incident Date: `date`" >> $FILE
    echo "Message: $SERVICE_NAME service is stopped/killed on this Node: \"$HOSTNAME\". Please check." >> $FILE
    aws sns publish --topic-arn $TOPIC_ARN --message  file://$FILE --subject "PRODUCTION ALERT :: $SERVICE_NAME Service is currently not running on \"$HOSTNAME\""
fi
}

function rmq_node_healthchk()
{
  local SERVICE_NAME="${1}"
  local HOSTNAME="${2:-$(hostname)}"
  local FILE="${3:-/tmp/${SERVICE_NAME}_healthcheck.txt}"
  local MESSAGE="${4:-/tmp/message.txt}"
  /usr/sbin/rabbitmqctl node_health_check > $FILE 2>&1
  local COUNT=`grep "Health check passed" $FILE | wc -l`

if [ "${COUNT}" -le "0" ]
then
   echo "BACKEND: Prod" > $MESSAGE
   echo "Service: $SERVICE_NAME" >> $MESSAGE
   echo "Incident Date: `date`" >> $MESSAGE
   echo "Message: $SERVICE_NAME is not responding on this Node: \"$HOSTNAME\". Please check." >> $MESSAGE
   aws sns publish --topic-arn $TOPIC_ARN --message  file://$MESSAGE --subject "PRODUCTION ALERT :: $SERVICE_NAME Health Check failed on \"$HOSTNAME\""
fi
}

function rmq_node_tcpalert()
{
local FILE_PATH="/var/log/rabbitmq/"
local SERVICE_NAME="${1}"
local HOSTNAME="${2:-$(hostname)}"
local FILE="$(find ${FILE_PATH} -type f -name *.net.log -ctime -5)"
local CHECKCOUNT=$(awk -v d1="$(date --date="-6 min" "+%F %H:%M:%S.%3N")" -v d2="$(date "+%F %H:%M:%S.%3N")" '$0 > d1 && $0 < d2 || $0 ~ d2' ${FILE} | grep -ci "rabbit_sysmon_handler busy_dist_port")
local MESSAGE="/tmp/tcp_alert_message"
if [ "${CHECKCOUNT}" -gt "0" ]
then
   echo "BACKEND: Prod" > $MESSAGE
   echo "Service: $SERVICE_NAME" >> $MESSAGE
   echo "Incident Date: `date`" >> $MESSAGE
   echo "Message: Alerts for inter-node tcp connection buffer exceeding the limit on this Node: \"$HOSTNAME\". Please check." >> $MESSAGE
aws sns publish --topic-arn $TOPIC_ARN --message  file://$MESSAGE --subject "PRODUCTION ALERT ::  $SERVICE_NAME on \"$HOSTNAME\""
fi

}

TYPE=$(hostname|cut -d'.' -f1|grep -E '^k|^m|^d|^z')
case $TYPE in
     kafka[0-9])
     service_stat kafka
     ;;
     zk[0-9])
     service_stat zookeeper
     ;;
     mq[0-9])
     service_stat rabbitmq_server
     rmq_node_healthchk Rabbitmq
     rmq_node_tcpalert "Rabbitmq tcp-buffer exceeding"
     ;;
     db[0-9])
     service_stat mongod
     ;;
esac
