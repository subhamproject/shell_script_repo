#!/usr/bin/env bash

usage() {
  echo Usage: $0 "

Below are the options

 Options:
  -v   Provide version you wish to install and configure in server?(eg: bash $0 -v 8 or -v 9)
"
}


DIR="/opt/tomcat"
APP_USER="tomcat"
APP_VERSION_9="http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.27/bin/apache-tomcat-9.0.27.tar.gz"
APP_VERSION_8="http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.47/bin/apache-tomcat-8.5.47.tar.gz"

function INSTALL_TOMCAT() {
APP_VER=$1
yum install java curl wget vim -y
mkdir -p ${DIR}
useradd -s /bin/false -d ${DIR} ${APP_USER}
wget ${APP_VER}  && \
tar xzvf  $(basename ${APP_VER}) -C ${DIR} --strip-components=1
chown -R ${APP_USER}:${APP_USER} ${DIR}
chmod -R g+rx ${DIR}/conf

cat <<! >> /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
Environment=CATALINA_Home=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=${APP_USER}
Group=${APP_USER}
UMask=0007
RestartSec=10
Restart=always

[Install]

WantedBy=multi-user.target
!
}

[ $# -eq 0 ] && usage && exit 1
while getopts "v:h" option; do
        case $option in
                v)
                   version=${OPTARG}
                   case $version in
                        8)
                         INSTALL_TOMCAT ${APP_VERSION_8}
                         [ $? -eq 0 ] && systemctl daemon-reload && \
                         systemctl enable ${APP_USER} && systemctl start ${APP_USER}
                         ;;
                        9)
                        INSTALL_TOMCAT ${APP_VERSION_9}
                        [ $? -eq 0 ] && systemctl daemon-reload && \
                        systemctl enable ${APP_USER} && systemctl start ${APP_USER}

                        ;;
                   esac
                  ;;
                h)
                  usage
                  ;;
         esac
done
