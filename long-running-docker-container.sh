#!/bin/bash    

TEMP_FILE="file.txt"
LIMIT="500"


function check_etl_timing() {
Date=$(date)
SERVER_CURRENT_TIME_INSEC=$(date -d "$Date" +%s)
CONTAINER_NAME=$(docker ps|grep -v agent|grep entry|awk '{print $1}'|head -1)
CONTAINER_START_TIME=$(docker inspect --format='{{.State.StartedAt}}' $CONTAINER_NAME)
CONTAINER_START_INSEC=$(date -d "$START" +%s)
TOTAL_RUN_TIME=$(($SERVER_CURRENT_TIME_INSEC-$CONTAINER_START_INSEC))
}


function alert() {
if [[ ! -f $TEMP_FILE ]] && [[ "$TOTAL_RUN_TIME" > "$LIMIT" ]];then
echo "ETL container with container ID: $CONTAINER_NAME is running more than $(($LIMIT/60))Minutes"
touch $TEMP_FILE
elif [[ "$TOTAL_RUN_TIME" < "$LIMIT" ]];then
rm -rf $TEMP_FILE
fi
}


check_etl_timing
alert
