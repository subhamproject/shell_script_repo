#!/bin/bash
# https://www.ghacks.net/2010/02/10/migrate-users-from-one-linux-machine-to-another/

sourceServer=172.16.1.55

function syncusers() {
echo -n "Do you have backups of your existing passwd files? [y|N] "
read
if [ "$REPLY" != "y" ]
then
        echo "Please back your files up and run this script again."
        exit 1
else
        scp $sourceServer:/etc/passwd /tmp/passwd.$sourceServer
        scp $sourceServer:/etc/group /tmp/group.$sourceServer
        scp $sourceServer:/etc/shadow /tmp/shadow.$sourceServer

        # First, make a list of non-system users that need to be moved.

        export UGIDLIMIT=500
        awk -v LIMIT=$UGIDLIMIT -F: '($3 >= LIMIT) && ($3 != 65534)' /tmp/passwd.$sourceServer > /tmp/passwd.mig
        awk -v LIMIT=$UGIDLIMIT -F: '($3 >= LIMIT) && ($3 != 65534)' /tmp/group.$sourceServer >/tmp/group.mig
        awk -v LIMIT=$UGIDLIMIT -F: '($3 >= LIMIT) && ($3 != 65534) { print $1 }' /tmp/passwd.$sourceServer \
| tee - |egrep -f - /tmp/shadow.$sourceServer > /tmp/shadow.mig

        # Now copy non-duplicate entries in to the new server files...
        while IFS=: read user pass uid gid full home shell
        do
                line="$user:$pass:$uid:$gid:$full:$home:$shell"
                exists=$(grep $user /etc/passwd)
                if [ -z "$exists" ]
                then
                        echo "Copying entry for user $user to new system"
                        echo $line >> /etc/passwd
                fi
        done </tmp/passwd.mig

        while IFS=: read group pass gid userlist
        do
                line="$group:$pass:$gid:$userlist"
                exists=$(grep $group /etc/group)
                if [ -z "$exists" ]
                then
                        echo "Copying entry for group $group to new system"
                        echo $line >> /etc/group
                fi
        done </tmp/group.mig

        while IFS=: read user pass lastchanged minimum maximum warn
        do
                line="$user:$pass:$lastchanged:$minimum:$maximum:$warn"
                exists=$(grep $user /etc/passwd)
                if [ -z "$exists" ]
                then
                        echo "Copying entry for user $user to new system"
                        echo $line >> /etc/shadow
                fi
        done </tmp/shadow.mig
       fi

}

echo "Copying user accounts and passwords from /etc/passwd"
syncusers
