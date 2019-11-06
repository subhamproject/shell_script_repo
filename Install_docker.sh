#!/bin/bash
##########################################################################################
#################### This script will be used to install docker && docker-compose" #######
##########################################################################################

[ $(id -u) -eq 0 ] && [ "$(uname -a|grep -i ubuntu|wc -l)" -ge "1" ] && [ "$(dpkg --get-selections | awk '/\Winstall/{print $1}'|grep -w "git$"|wc -l)" -le "0"  -a "$(dpkg --get-selections | awk '/\Winstall/{print $1}'|grep -w "wget$"|wc -l)" -le "0" ] && apt-get update && apt-get install -y wget \
                                                                                                                                                                                                                                                                                          git
[ $(id -u) -eq 0 ] && [ "$(uname -a|grep -i ubuntu|wc -l)" -le "0" ] && [ -f /etc/yum.repos.d/CentOS-Base.repo ] && sed  -i '/updates/,+6 s/^/#/'  /etc/yum.repos.d/CentOS-Base.repo && sed  -i '/extras/,+6 s/^/#/'  /etc/yum.repos.d/CentOS-Base.repo
[ $(id -u) -eq 0 ] && [ "$(uname -a|grep -i ubuntu|wc -l)" -le "0" ] && [ "$(rpm -qa|grep -w "git$"|wc -l)" -le "0" -a "$(rpm -qa|grep -w "get$"|wc -l)" -le "0" ]  && yum install -y wget \
                                                                                                                                                                        git

###### Funtion to install Docker in AWS EC2/Ubuntu/Centos
install_docker ()
{
# Install docker
if [ ! -f /etc/redhat-release -a "$(uname -a|grep -i ubuntu|wc -l)" -le "0" -a "$(which docker|wc -l)" -le "0" ];then
   yum install docker -y
   usermod -a -G docker ${USER}
elif [ "$(uname -a|grep -i ubuntu|wc -l)" -ge "1" -a "$(which docker|wc -l)" -le "0" ] ;then
   wget -qO- https://get.docker.com/ | sh
elif [ "$(uname -a|grep -i ubuntu|wc -l)" -le "0" -a "$(which docker|wc -l)" -le "0" ];then
cat > /etc/yum.repos.d/extras.repo <<- 'EOF'
#CentOS extras repository
[extras]
name=CentOS 7 extras Repository
baseurl=http://mirror.centos.org/centos/7/extras/x86_64/
gpgcheck=0
enabled=1
EOF
[ $? -eq 0 ] && wget -qO- https://get.docker.com/ | sh
else
 echo "Docker already installed..Skipping installing it!!"
fi
}

###### Funtion to install docker-compose in AWS EC2/Ubuntu/Centos
install_docker_compose ()
{
if [ "$(which docker-compose|wc -l)" -le "0" ];then
# Install docker-compose
COMPOSE_VERSION=$(git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9]+\.[0-9]+$" | tail -n 1)
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
else
echo "Docker compose already installed..Skipping installing it!!"
fi
}

#### Function to Start Docker,It will start docker based on the OS version
start_docker ()
{
[ "$(which docker|wc -l)" -ge "1" ] && [ "$(uname -a|grep -i ubuntu|wc -l)" -le "0" ] && [ -f /etc/redhat-release ] && systemctl enable docker && systemctl start docker
[ "$(which docker|wc -l)" -ge "1" ] && [ "$(uname -a|grep -i ubuntu|wc -l)" -le "0" ] && [ ! -f /etc/redhat-release ]  && service docker start
[ "$(which docker|wc -l)" -ge "1" ] && [ "$(uname -a|grep -i ubuntu|wc -l)" -ge "1" ] && [ "$(lsb_release -r|awk '{print $2}'|cut -d'.' -f1)" -le "14" ] && service docker start
[ "$(which docker|wc -l)" -ge "1" ] && [ "$(uname -a|grep -i ubuntu|wc -l)" -ge "1" ] && [ "$(lsb_release -r|awk '{print $2}'|cut -d'.' -f1)" -ge "16" ] && systemctl start docker
}

##### Calling actual Function
if [ $(id -u) -eq 0 ]
  then
  install_docker
  [ $? -eq 0 ] && install_docker_compose || exit 1
  start_docker
else
  echo "You must be root to run this script $0"
fi
