#!/bin/bash

DIR="/sonarqube"

function install_sonar() 
{
yum remove java-1.7.0-openjdk -y
yum install java-1.8.0 -y
[ ! -d $DIR ] && mkdir -p $DIR
cd $DIR && wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.7.zip && unzip sonarqube-*.zip && rm -rf sonarqube-*.zip && mv sonarqube-7.* sonar
useradd -c "Sonarqube Default Account" -s /bin/bash sonar && chown -R sonar:sonar $DIR/sonar && echo "sonar - nofile  65536" >> /etc/security/limits.conf && echo "sonar - nproc 2048" >> /etc/security/limits.conf
sed -i 's|#sonar.jdbc.username=.*|sonar.jdbc.username=sonar|; s|#sonar.jdbc.password=.*|sonar.jdbc.password=sonar|; s|#sonar.jdbc.url=jdbc:postgresql.*|sonar.jdbc.url=jdbc:postgresql://localhost/sonar|' $DIR/sonar/conf/sonar.properties
}

function install_postgres()
{
yum install postgresql96-server postgresql96-contrib -y && mkdir -p /postgres && chown -R postgres:postgres /postgres && su - postgres bash -c 'initdb /postgres' && \
su - postgres bash -c 'pg_ctl -D /postgres -l logfile start' && echo "postgres" | passwd --stdin postgres && sleep 5
su - postgres << EOF
createuser sonar
psql
ALTER USER sonar WITH ENCRYPTED password 'sonar';
CREATE DATABASE sonar OWNER sonar;
\q
EOF
}

function start_sonar()
{
sleep 5
chown -R sonar:sonar /sonarqube/ && \
ln -s $DIR/sonar/bin/linux-x86-64/sonar.sh /etc/init.d/sonar && sed -i 's|#RUN_AS_USER=.*|RUN_AS_USER=sonar|; s|^WRAPPER_CMD=.*|WRAPPER_CMD="/sonarqube/sonar/bin/linux-x86-64/wrapper"|; s|^WRAPPER_CONF=.*|WRAPPER_CONF="/sonarqube/sonar/conf/wrapper.conf"|' /etc/init.d/sonar && \
chkconfig sonar on
service sonar start
}

install_sonar
install_postgres
start_sonar
