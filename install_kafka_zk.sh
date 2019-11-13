#!/bin/bash

function usage() {
echo "Usage: $0 -s <single> (or) -m <multi>"
exit 1
}

function add_user() {
useradd -m kafka
}

function install_pkgs() {
yum install java wget curl vim -y
}

function download_and_extract() {
curl http://apachemirror.wuchna.com/kafka/2.3.1/kafka_2.12-2.3.1.tgz -o /home/kafka/kafka.tgz
mkdir -p /home/kafka/kafka
cd $_ && tar -xvzf /home/kafka/kafka.tgz --strip 1 && chown -R kafka:kafka /home/kafka/*
}

function create_multi_kafka_config() {
for num in 0 1 2
do
cat <<! >> /home/kafka/kafka/config/server${num}.properties
broker.id=${num}
port=909${num}
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/tmp/kafka-logs-${num}
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181,localhost:2182,localhost:2183
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
!
done
}

function create_multi_zk_config() {
for num in 1 2 3
do
mkdir -p /tmp/zookeeper-${num}
echo "${num}" > /tmp/zookeeper-${num}/myid
cat <<! >> /home/kafka/kafka/config/zookeeper${num}.properties
tickTime=2000
dataDir=/tmp/zookeeper-${num}
clientPort=218${num}
initLimit=5
syncLimit=2
server.1=localhost:2666:3666
server.2=localhost:2667:3667
server.3=localhost:2668:3668
!
done
chown -R kafka:kafka /tmp/*
}


function create_single_kafka_config() {
cat <<! >> /etc/systemd/system/kafka.service
[Unit]
Description=Apache Kafka
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple

User=kafka
Group=kafka

ExecStart=/home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties
ExecStop=/home/kafka/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
!
}

function create_single_zk_config() {
cat <<! >> /etc/systemd/system/zookeeper.service
[Unit]
Description=zookeeper
After=syslog.target network.target

[Service]
Type=simple

User=kafka
Group=kafka

ExecStart=/home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper.properties
ExecStop=/home/kafka/kafka/bin/zookeeper-server-stop.sh

[Install]
WantedBy=multi-user.target
!
}

function start_single_kafka_zk() {
systemctl daemon-reload
systemctl start zookeeper && sleep 30
systemctl start kafka
}

function start_multi_kafka_zk() {
nohup /home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper1.properties > /tmp/zk1.out 2>&1& 
sleep 10
nohup /home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper2.properties > /tmp/zk2.out 2>&1&
sleep 10
nohup /home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper3.properties > /tmp/zk3.out 2>&1&
sleep 60
nohup /home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server0.properties > /tmp/kafka1.out 2>&1&
sleep 10
nohup /home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server1.properties > /tmp/kafka2.out 2>&1&
sleep 10
nohup /home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server2.properties > /tmp/kafka3.out 2>&1&
}

while getopts ':s:m:h' option
do
case $option in
  s) single=$OPTARG
     [ "${single}" == "single" ]  && \
     echo "Configuring Single node kafka and zookeeper in this server: $(hostname)" && \
     add_user && \
     install_pkgs && \
     download_and_extract && \
     create_single_kafka_config && \
     create_single_zk_config && \
     start_single_kafka_zk && \
     echo "Setup is completed,You can start using single node kafka and zookeeper" || echo "Please use $0 -s single or -m multi"
     ;;
  m) multi=$OPTARG
     [ "${multi}" == "multi" ] && \
     echo "Configuring Multi node kafka and zookeeper in this server: $(hostname)" && \
     add_user && \
     install_pkgs && \
     download_and_extract && \
     create_multi_kafka_config && \
     create_multi_zk_config && \
     start_multi_kafka_zk && \
     echo "Setup is completed,You can start using multi node kafka and zookeeper, Please check nohup outputs in /tmp for each service" || echo "Please use $0 -s single or -m multi"
    ;;
  h) usage
    ;;
esac
done
