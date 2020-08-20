# Generic script to install sonarqube with postgress in any flavour of linux
# https://gist.github.com/ikennaokpala/7547006
#!/bin/bash

DIR="/sonarqube"

function install_pkg()
{
if grep -iE 'amazon|centos' /etc/os-release >> /dev/null;then
  yum remove java-1.7.0-openjdk -y
  yum install java-1.8.0 unzip wget curl -y
elif grep -i ubuntu /etc/os-release >> /dev/null;then
  yes ' '|add-apt-repository ppa:openjdk-r/ppa
  apt-get update && apt-get install openjdk-8-jdk unzip wget curl -y
fi
}

function install_sonar() 
{
 [ ! -d $DIR ] && mkdir -p $DIR
 cd $DIR && wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.7.zip && unzip sonarqube-*.zip && rm -rf sonarqube-*.zip && mv sonarqube-7.* sonar
 useradd -c "Sonarqube Default Account" -s /bin/bash sonar && chown -R sonar:sonar $DIR/sonar && echo "sonar - nofile  65536" >> /etc/security/limits.conf && echo "sonar - nproc 2048" >> /etc/security/limits.conf
 sed -i 's|#sonar.jdbc.username=.*|sonar.jdbc.username=sonar|; s|#sonar.jdbc.password=.*|sonar.jdbc.password=sonar|; s|#sonar.jdbc.url=jdbc:postgresql.*|sonar.jdbc.url=jdbc:postgresql://localhost/sonar|' $DIR/sonar/conf/sonar.properties
}

function install_postgres()
{
if grep -i amazon /etc/os-release >> /dev/null;then
   [ $(cat /etc/os-release |grep -m1 VERSION|cut -d'=' -f2|sed 's|"||g') -ne '2' ] && \
   yum install postgresql96-server postgresql96-contrib -y || \
   amazon-linux-extras install postgresql10 epel -y &&  yum update -y && yum install -y postgresql-server postgresql-devel
   mkdir -p /postgres && chown -R postgres:postgres /postgres && su - postgres bash -c 'initdb /postgres' && \
   su - postgres bash -c 'pg_ctl -D /postgres -l logfile start' && echo "postgres" | passwd --stdin postgres && sleep 5
cat <<! >> /usr/bin/postgresql
#!/bin/bash
# chkconfig: 345 20 80
# description: postgres
TYPE=\$1
case \$TYPE in
  status)
  su - postgres bash -c 'pg_ctl -D /postgres -l logfile status'
  ;;
  start)
  su - postgres bash -c 'pg_ctl -D /postgres -l logfile start'
  ;;
  stop)
  su - postgres bash -c 'pg_ctl -D /postgres -l logfile stop'
  ;;
 esac
!
    chmod a+x /usr/bin/postgresql && ln -s /usr/bin/postgresql /etc/init.d/postgres
elif grep -i centos /etc/os-release >> /dev/null;then
     yum install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm -y && \
     yum -y install postgresql10 postgresql10-server postgresql10-contrib postgresql10-libs postgresql10-devel
     systemctl enable postgresql-10.service && /usr/pgsql-10/bin/postgresql-10-setup initdb
     systemctl start postgresql-10.service
    find / -type f -name "pg_hba.conf"|head -1 |xargs sed -i 's|peer|trust|g; s|ident|md5|g' && systemctl restart postgresql-10.service
elif grep -i ubuntu /etc/os-release >> /dev/null;then
   echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | sudo tee /etc/apt/sources.list.d/pgdg.list
   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
   sudo apt-get update && sudo apt-get install postgresql-10 -y
fi
}


function create_db_user()
{
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
 sleep 5 && chown -R sonar:sonar $DIR && \
 ln -s $DIR/sonar/bin/linux-x86-64/sonar.sh /etc/init.d/sonar && sed -i 's|#RUN_AS_USER=.*|RUN_AS_USER=sonar|; s|^WRAPPER_CMD=.*|WRAPPER_CMD="/sonarqube/sonar/bin/linux-x86-64/wrapper"|; s|^WRAPPER_CONF=.*|WRAPPER_CONF="/sonarqube/sonar/conf/wrapper.conf"|; s|^PIDDIR=.*|PIDDIR="/sonarqube/sonar/"|' /etc/init.d/sonar && \
if grep -iE 'amazon|centos' /etc/os-release >> /dev/null;then
   chkconfig sonar on && service sonar start
elif grep -i ubuntu /etc/os-release >> /dev/null;then
    /etc/init.d/sonar start
fi  
}


install_pkg
install_sonar
install_postgres
create_db_user
start_sonar
