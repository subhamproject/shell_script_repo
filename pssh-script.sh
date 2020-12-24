
#https://www.tecmint.com/execute-commands-on-multiple-linux-servers-using-pssh/
#https://www.cyberciti.biz/cloud-computing/how-to-use-pssh-parallel-ssh-program-on-linux-unix/
#https://www.golinuxcloud.com/pssh-commands-parallel-ssh-linux-examples/
#https://www.cyberithub.com/pssh-examples-in-linux-parallel-ssh/
#!/bin/bash

shopt -s xpg_echo

SERVER_LIST="servers_list.txt"
USER_NAME="vagrant"
STD_ERROR="/tmp/error"
STD_OUT="/tmp/out"

pssh -e $STD_ERROR -o $STD_OUT -v  -h $SERVER_LIST -A -i -l $USER_NAME -I <<EOF
df -h
EOF
