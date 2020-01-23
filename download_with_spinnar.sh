#!/bin/bash

shopt -s xpg_echo

echo -n "Downloading nexus from source:  "
while true; do for X in '/' '-' '\' '|'; do echo -en "\b$X"; sleep 0.1; done; done &
PID=$!
trap 'kill $PID' EXIT
[ ! -e latest-unix.tar.gz ] && wget -q http://download.sonatype.com/nexus/3/latest-unix.tar.gz || { echo "\nNexus file already exit in current path." ; exit 1 ; }
[ $? -eq 0 ] && echo "\nNexus download was successful." && kill $PID
