#!/bin/bash

#https://releases.ansible.com/ansible-tower/setup/?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW


function check_os_supported() {
case $(egrep '^(NAME)=' /etc/os-release|cut -d'=' -f2|sed 's|"||g') in
"Amazon Linux")
echo "THIS OS IS NOT SUPPORTED FOR ANSIBLE TOWER"
echo "PLEASE TRY IN OTHER OS - RHEL (or) CENTOS"
exit 1
;;
*)
:
;;
esac
}


function check_hardware_requirement() {
check_os_supported
[[ ! $(grep '^processor' /proc/cpuinfo | sort -u | wc -l) -ge 2 ]] && { echo "Please upgrade your server with at least 2 core CPU" ; exit 1 ; }
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_GB=$(expr $RAM_KB / 1024 / 1024)
[[ ! $RAM_GB -ge 7 ]] &&  { echo "Please upgrade your server with at least 8GB RAM" ; exit 1 ; }
[[ ! $(df -h|grep -vE 'tmpfs|devtmpfs|docker'|sed '1d'|awk '{print $2}'|sed 's|G||g') -ge 20 ]] &&  { echo "Please create at least 20GB Filesystem for Tower" ; exit 1 ; }
}


function main() {
check_hardware_requirement

DATA_DIR="/data"

TOWER_VERSION=${1:-ansible-tower-setup-3.7.0-4.tar.gz}

curl  https://releases.ansible.com/ansible-tower/setup/${TOWER_VERSION} -o /tmp/tower.tar.gz
[ ! -d $DATA_DIR ] && mkdir -p $DATA_DIR
cd $_ && tar xvzf /tmp/tower.tar.gz --strip 1
if [[ -f inventory ]] ;then
sed -i "/^admin_password=/s;=.*$;='password';" inventory
sed  -i "/^pg_password=/s;=.*$;='password';" inventory
fi
bash setup.sh
[ $? -eq 0 ] && \
echo -e '\n'
printf "ANSIBLE TOWER SETUP HAS BEEN DONE  - PLEASE TRY TO ACCESS IT VIA SERVER IP.."
echo " OK!"
printf "DEFAULT LOGIN ID IS :- admin.."
echo " OK!"
printf "DEFAULT LOGIN PASSWORD IS :- password.."
echo " OK!"
printf "PLEASE IMPORT LICENSE KEY IF YOU ALREADY HAVE - IF NOT REQUEST FOR TRAIL VERSION IN REDHAT SITE.."
echo " OK!"
}

main
