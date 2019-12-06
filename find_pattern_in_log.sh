#!/bin/bash

IFS=$'\n'

: ${TEMP_FILE:=/tmp/log_patterns$$.txt}
: ${EMAIL_FILE1:=/tmp/send_email1_once.txt}
: ${EMAIL_FILE2:=/tmp/send_email2_once.txt}
: ${CONTAINER_FILE:=/tmp/container_name.txt}
: ${FILE:=/tmp/log_file.txt}
: ${FILE1:=/tmp/log_file1.txt}
: ${TOPIC_ARN:="arn:aws:sns"}

function delete_temp_file(){
 rm -rf $TEMP_FILE
 eval check_container
}

function delete_email_file_first(){
[ -f $EMAIL_FILE1 ] && rm -rf $EMAIL_FILE1
[ -f $FILE1 ] && rm -rf $FILE1
#[ -f $FILE ] && rm -rf $FILE
}

function delete_email_file_second(){
[ -f $EMAIL_FILE2 ] && rm -rf $EMAIL_FILE2
#[ -f $FILE ] && rm -rf $FILE
}

function send_mail_start(){
[ -s "$FILE" ] && \
aws sns publish --region ap-southeast-1 --topic-arn $TOPIC_ARN --message  file://$FILE --subject "ALERT:: ETL job Started"
}

function send_mail_finished(){
if [[ -s "$FILE" ]] && [[ $(cat $FILE|wc -l) -gt 4 ]];then
aws sns publish --region ap-southeast-1 --topic-arn $TOPIC_ARN --message  file://$FILE --subject "ALERT:: ETL Job finished with Errors"
elif [[ -s "$FILE" ]] && [[ $(cat $FILE|wc -l) -eq 4 ]];then
aws sns publish --region ap-southeast-1 --topic-arn $TOPIC_ARN --message  file://$FILE --subject "ALERT:: ETL Job finished"
fi
}


function export_env(){
echo "BACKEND: Dev" > $FILE
echo "TENANT:  Dev" >> $FILE
echo "Service: DB" >> $FILE
}

CONTAINER_NAME=$(docker ps|grep -v agent|grep entry|awk '{print $1}'|head -1)
[ -n "$CONTAINER_NAME" ] && echo $CONTAINER_NAME > $CONTAINER_FILE || :

function check_container(){
while read name
do
 if ! docker ps |sed '1d'|grep -v agent|grep $name >> /dev/null;then
   eval delete_email_file_first
 else
   eval delete_email_file_second
 fi
done <$CONTAINER_FILE
}

trap delete_temp_file  EXIT

#Find latest log file
#LOG_FILE="$(find /pentaho/storage/logs -name "rcx*" -type f  -mmin -60 -ls|awk '{print $NF}'|xargs basename)"
LOG_FILE="/storage/logs/$1"

function pdi_start() {
local PATTERN=$1
case $PATTERN in
  "Kitchen - Start of run")
    if [ ! -f $EMAIL_FILE1 ];then
    PDI_START_TIME="$(cat $LOG_FILE|grep "$PATTERN"|awk -F'-' '{print $1}')"
    [ -n "$PDI_START_TIME" ] && export_env &&  \
    echo "ETL job Started at:  $PDI_START_TIME"
    fi
  ;;
esac
}

function pdi_end() {
local PATTERN=$1
case $PATTERN in
 "Kitchen - Finished!")
     if [ ! -f $EMAIL_FILE2 ];then
     PDI_END_TIME="$(cat $LOG_FILE|grep "$PATTERN"|awk -F'-' '{print $1}')"
     [ -n "$PDI_END_TIME" ] && export_env && \
     echo "ETL job Finished at: $PDI_END_TIME"
     fi
   ;;
  "Kitchen - Start of run")
    :
   ;;
 "Finished with errors")
   if [ ! -f $EMAIL_FILE2 ];then
   if [ -z "$(cat $LOG_FILE|grep "Kitchen - Finished!"|awk -F'-' '{print $1}')" ];then
      export_env
      echo "--------------------------------------------------------" > $FILE1
      echo "Job was killed or container got killed unexpectedly" >> $FILE1
   fi
   fi
   ;;
  *)
   if [ ! -f $EMAIL_FILE2 ];then
   if grep "$PATTERN" $LOG_FILE >> /dev/null ;then
   echo "--------------------------------------------------------" > $FILE1
   grep "$PATTERN" $LOG_FILE |head -2 >> $FILE1
   fi
   fi
  ;;
esac
}

function create_tmp_file(){
cat <<! > $TEMP_FILE
Kitchen - Start of run
error connecting to db server
unexpected ISODate format
connection timed out
Temporary failure in name resolution
invalid
Couldn't
No such file or directory
syntax error at or near
ERROR:
stl_load_errors
error occurred
Syntax error
Unexpected error
it is not a file
ValueError:
Cursor not found
Name or service not known
Finished with errors
Kitchen - Finished!
!
}


function check_pdi_errors(){
 while read error
 do
if docker ps |sed '1d'|grep -v agent >> /dev/null;then
 pdi_start $error
else
 pdi_end $error
fi
 done <$TEMP_FILE >> $FILE
}

create_tmp_file
check_pdi_errors

[ -f $FILE1 ] && cat $FILE1 >> $FILE


if [[ ! -f $EMAIL_FILE1 ]] && [[ -n "$CONTAINER_NAME" ]];then
send_mail_start
touch $EMAIL_FILE1
elif [[ ! -f $EMAIL_FILE2 ]] && [[ -z "$CONTAINER_NAME" ]];then
send_mail_finished
touch $EMAIL_FILE2
fi
