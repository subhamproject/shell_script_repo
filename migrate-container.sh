#!/bin/bash
#
# Filename : migrate
# Description : Migrate Proxmox OpenVZ container from one storage to another
# Author : James Coyle
#
# Version:
# -Date       -Author      -Description
# 20-11-2013  James Coyle  Initial
# 13-12-2017  James Coyle  Changes for LXC
#
#

# Variables
TMP=/tmp      #Location to use to create the backup for transferring to new storage. This needs to be big enough to store the backup archive for the container.

# Do not edit
usage() { 
	echo "Usage: $0" 
	echo "          [-c Required: Container ID to migrate <int>] "
	echo "          [-s Required: Target storage ID <string>]"
	echo "          [-d Optional: Delete the backup file after CT restoration <boolean>]"
	echo ""
	echo "Example: $0 -c 100 -s nasarray"
	echo ""
	exit 1; 
}

while getopts "c:s:d" o; do
  case "${o}" in
    c)
      CT=${OPTARG}
      ;;
    s)
      TARGET_STORAGE=${OPTARG}
      ;;
    d)
      DELETE=true
      ;;
    *)
      usage
      ;;
    esac
done
shift $((OPTIND-1))

# Check mandatory fields
if [ -z "${CT}" ] || [ -z "${TARGET_STORAGE}" ]; then
  usage
fi

RUNNING=false

set -e
set -o pipefail

echo "Moving $CT to $TARGET_STORAGE..."
if pct list| fgrep -w -q "$CT" | grep "running"
then
    RUNNING=true
fi

if $RUNNING
then
    pct stop $CT
fi

vzdump --dumpdir $TMP $CT

ARCHIVE=$(ls -t $TMP/vzdump-lxc-$CT-*.tar | head -n 1)

pct restore $CT $ARCHIVE -force -storage $TARGET_STORAGE

if $RUNNING
then
    pct start $CT
fi

if $DELETE
then
    LOG=$(ls -t $TMP/vzdump-lxc-$CT-*.log | head -n 1)
    echo "Deleting $LOG and $ARCHIVE"
    rm -rf $ARCHIVE $TMP/$LOG
fi
