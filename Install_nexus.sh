#!/bin/bash

## 
[ ! -d /nexus ] && mkdir -p /nexus

cd /nexus && wget https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.16.1-02-unix.tar.gz
https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.17.0-01-unix.tar.gz

tar xvf latest-unix.tar.gz &&  mv nexus-3.* nexus && rm -rf sonatype-work && useradd  -c "Nexus Artifact Account"  nexus \
&& chown -R nexus:nexus /nexus

sed -i 's|#run_as_user=""|run_as_user="nexus"|' ./nexus/bin/nexus.rc && mkdir -p /nexus/nexus-data && chown nexus:nexus /nexus/nexus-data

sed -i 's|^-Dkaraf.data=.*|-Dkaraf.data=/nexus/nexus-data|; s|^-Djava.io.tmpdir=.*|-Djava.io.tmpdir=data/tmp|; s|^-XX:LogFile=.*|-XX:LogFile=/nexus/nexus-data/log/jvm.log|' ./nexus/bin/nexus.vmoptions \
&&  && echo "nexus - nofile 65536" >> /etc/security/limits.conf && ln -s /nexus/nexus/bin/nexus /etc/init.d/nexus && /etc/init.d/nexus start









================================================================================================================================

#!/bin/bash

[ ! -d /nexus ] && mkdir -p /nexus
cd /nexus && wget wget http://download.sonatype.com/nexus/3/latest-unix.tar.gz
https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.17.0-01-unix.tar.gz
tar xvf latest-unix.tar.gz &&  mv nexus-3.* nexus && rm -rf sonatype-work \
&& useradd  -c "Nexus Artifact Account"  nexus \
&& mkdir -p /nexus-data && chown -R nexus:nexus /nexus
sed -i 's|#run_as_user=""|run_as_user="nexus"|' ./nexus/bin/nexus.rc \
&& chown nexus:nexus /nexus-data
sed -i 's|^-Dkaraf.data=.*|-Dkaraf.data=/nexus-data|; s|^-Djava.io.tmpdir=.*|-Djava.io.tmpdir=data/tmp|; s|^-XX:LogFile=.*|-XX:LogFile=/nexus-data/log/jvm.log|' ./nexus/bin/nexus.vmoptions \
&& echo "nexus - nofile 65536" >> /etc/security/limits.conf && ln -s /nexus/nexus/bin/nexus /etc/init.d/nexus
chkconfig nexus on
service nexus start
