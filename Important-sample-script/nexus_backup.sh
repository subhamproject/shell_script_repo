#!/bin/bash

BACKUP_DIR="/nexus-backup"
[ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR}
NOW="$(date +%d%m%Y-%H%M)"
BACKUP_NAME="nexus-backup-${NOW}.tar.lz4"
DATA_DIR_PATH="/nexus /nexus-data"

tar  cf - $DATA_DIR_PATH  -P| lz4 -v --no-sparse > $BACKUP_DIR/$BACKUP_NAME
[ $? -eq 0 ] && echo "backup was success - Please check backup in $BACKUP_DIR path and backup name is: $BACKUP_NAME"
