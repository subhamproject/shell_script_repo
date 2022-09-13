#!/bin/bash

#https://encore.tech/automating-red-hat-enterprise-linux-patching-with-ansible-part-2-of-2/

# @brief actions required to be conducted before updates are applied
#        and/or servers are rebooted.  
logFile="/tmp/pre_update.log"
###########################
# Begin Functions         #
function log_msg {
  current_time=$(date "+%Y-%m-%d %H:%M:%S.%3N")
  log_level=$1
  # all arguments except for the first one, since that is the level
  log_msg="${@:2}"
  echo "[$current_time] $log_level - $log_msg" >> $logFile
}

function log_error {
  log_msg "ERROR" "$@"
}
function log_info {
  log_msg "INFO " "$@"
}
function log_debug {
  log_msg "DEBUG" "$@"
}
# End Functions           #
###########################
###########################
# Begin Body              #
errorCheck=0
cat /dev/null > $logFile
log_info "========================================================"
log_info "= Pre-update status for $HOSTNAME"
log_info "========================================================"
