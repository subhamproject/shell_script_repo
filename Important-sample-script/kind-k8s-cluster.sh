#!/bin/bash

K8S_TEMPLTE="/tmp/k8s_cluster.yaml"

function check_cmd(){
[ -z $(command -v kind) ] &&   curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64  && \
                                      chmod +x ./kind && \
                                      mv ./kind /usr/bin/kind
[ -z $(command -v kubectl) ] && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
                                       chmod +x ./kubectl && \
                                       mv ./kubectl /usr/bin/kubectl
[ -z $(command -v docker) ] &&  curl -fsSL https://get.docker.com -o get-docker.sh && \
                                       sh get-docker.sh && \
                                       systemctl start docker && \
                                       systemctl enable docker
}



function setup_k8s_cluster() {
cat << EOF > $K8S_TEMPLTE
# a cluster with 3 control-plane nodes and 3 workers
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

#kind create cluster --name first_k8s_clster --config $K8S_TEMPLTE
kind create cluster --config $K8S_TEMPLTE
}

if [ $(id -u ) -eq 0 ];then
    check_cmd
    setup_k8s_cluster
    echo "You can start using k8s cluster - kubectl get nodes (or) kubectl cluster-info"
else
   echo "You must be root to run this script: $0"
fi
