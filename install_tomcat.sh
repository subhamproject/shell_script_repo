#!/usr/bin/env bash

DIR="/opt/tomcat"
APP_USER="tomcat"


function INSTALL_TOMCAT() {
yum install java curl wget vim -y
mkdir -p ${DIR}
useradd -s /bin/false -d ${DIR} ${APP_USER}
wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.27/bin/apache-tomcat-9.0.27.tar.gz && \
tar xzvf apache-tomcat-9.0.27.tar.gz -C ${DIR} --strip-components=1
chown -R ${APP_USER}:${APP_USER} ${DIR}
chmod -R g+rx ${DIR}/conf

cat <<! >> /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64/jre
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

INSTALL_TOMCAT
systemctl daemon-reload && \
systemctl enable ${APP_USER} && systemctl start ${APP_USER}
