
IMP

#https://stackoverflow.com/questions/27599839/how-to-wait-for-an-open-port-with-netcat


#!/bin/bash

echo "Waiting jenkins to launch on 8080..."

while ! timeout 1 bash -c "echo > /dev/tcp/localhost/8080"; do   
  sleep 1
done

echo "Jenkins launched"



#!/bin/bash

echo "Waiting jenkins to launch on 8080..."

while ! nc -z localhost 8080; do   
  sleep 0.1 # wait for 1/10 of the second before check again
done

echo "Jenkins launched"

#!/bin/bash
 
opened=0
 
while [ "$opened"  == "0" ]; do
  echo "Waiting jenkins to launch on 8080..."
  nc -vz localhost 8080
done
 
echo "Jenkins launched"




for EXPONENTIAL_BACKOFF in {1..10}; do
    nc -w 1 -z db.local 3306 && break;
    DELAY=$((2**$EXPONENTIAL_BACKOFF))
    echo "db not yet available, sleeping for $DELAY seconds"
    sleep $DELAY
done
