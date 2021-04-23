#!/bin/bash
# Script to clone specific directory from remote git repo to local server.

LOCAL_FOLDER_PATH="/tmp/single_folder"
REMOTE_REPO="https://github.com/subhamproject/shell_script_repo.git"
FOLDER_TO_CLONE="Important-sample-script"


[ ! -d $LOCAL_FOLDER_PATH ] && mkdir -p $LOCAL_FOLDER_PATH
[ -d $FOLDER_NAME ] && ( cd $LOCAL_FOLDER_PATH ; git init )

( cd $LOCAL_FOLDER_PATH ; git remote add origin -f $REMOTE_REPO
[ $? -eq 0 ] && git config core.sparsecheckout true && \
               echo "$FOLDER_TO_CLONE" >> .git/info/sparse-checkout && \
               git pull origin master && \
               echo "Folder \"$FOLDER_TO_CLONE\"  is successfully clone in \"$LOCAL_FOLDER_PATH\" path" || echo "Could not clone,Please check and try again" )
