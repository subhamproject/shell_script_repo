#!/bin/bash

shopt -s xpg_echo

echo -n "Downloading nexus from source:  "
while true; do for X in '/' '-' '\' '|'; do echo -en "\b$X"; sleep 0.1; done; done &
PID=$!
trap 'kill $PID' EXIT
[ ! -e latest-unix.tar.gz ] && wget -q http://download.sonatype.com/nexus/3/latest-unix.tar.gz || { echo "\nNexus file already exit in current path." ; exit 1 ; }
[ $? -eq 0 ] && echo "\nNexus download was successful." && kill $PID


==================================================================================================================================
#!/bin/bash

shopt -s xpg_echo

spinnar() {
while true; do for X in '/' '-' '\' '|'; do echo -en "\b$X"; sleep 0.1; done; done &
}

trap 'kill $(jobs -p)' EXIT


download_1() {
echo -n "Downloading nexus from source:  "
spinnar
wget -q http://download.sonatype.com/nexus/3/latest-unix.tar.gz
[ $? -eq 0 ] && echo "\nNexus download was successful."
}

download_2() {
echo -n "Downloading nexus from soure-second time:  "
wget -q http://download.sonatype.com/nexus/3/latest-unix.tar.gz
[ $? -eq 0 ] && echo "\nNexus download was successful..second time."
}


download_1
download_2



