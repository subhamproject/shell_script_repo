#!/bin/bash

for LINE in $(cat file.txt);do
SERVICENAME=$LINE
MONITOR_NAME=${SERVICENAME:+docker-$SERVICENAME}
echo "Service name is:- $SERVICENAME"
echo "Monitor name is:- $MONITOR_NAME"
done
~
