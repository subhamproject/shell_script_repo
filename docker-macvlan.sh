#!/bin/bash

#NOTE you can create only one macvlan with one ethernet,if you try to use it again it will fail

SYSTEM_IP=$(ip addr show|grep global|grep -vE 'lxd*|docker'|grep -v inet6|awk '{print $2}')
ETH_ADDR=$(ip addr show|grep global|grep -vE 'lxd*|docker'|grep -v inet6|awk '{print $NF}')
GATE_WAY=$(echo ${SYSTEM_IP}|cut -d'/' -f1|awk -F"." '{print $1"."$2"."$3".1"}')


read -p "Please provide the macvlan network name you wish to create? : " macvlan_name
[ -n "$(docker network ls |grep ${macvlan_name})" ] && echo "macvlan network \"${macvlan_name}\" already present in this host,please try new name and try again" && exit 1
[ -z "$(docker network ls |grep ${macvlan_name})" ] && docker network create -d macvlan --subnet=${SYSTEM_IP} --gateway=${GATE_WAY}  -o parent=${ETH_ADDR} ${macvlan_name} >> /dev/null
[ $? -eq 0 ] && echo "macvlan network \"${macvlan_name}\"created for docker,you can start using it"

read -p "would you like to create a container and see how this works?(yes/no) : " answers

case $answers in
        yes|YES)
          echo "lets create a nginx container using macvlan network \"${macvlan_name}\" and see how this works"
          docker run --net=${macvlan_name} -d --name my-nginx-$$ nginx  >> /dev/null
          [ $? -eq 0 ] && echo -e "you can access nginx from your laptop browser with following ip: "
          IP_ADD=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my-nginx-$$)
          echo -e "IP Addrs: ${IP_ADD}"
          ;;
         no|NO)
         echo -e "you choose not to try out macvlan \"${macvlan_name}\" network,exiting" && exit 0
         ;;
esac
