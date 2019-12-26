#!/bin/bash

function git_clone() {
GIT_URL="https://github.com/justmeandopensource/kubernetes.git"
git clone $GIT_URL
(cd kubernetes/lxd-provisioning; lxc profile create k8s; lxc profile edit k8s < k8s-profile-config)
}

function install_lxd() {
apt-get update && apt-get install lxd -y && sleep 10
systemctl start lxd
lxd init && lxc list
}

function setup_k8s_cluster() {
command -v lxc >/dev/null 2>&1 || { echo >&2 "lxc not installed.  Aborting."; exit 1; }
command -v lxd >/dev/null 2>&1 || { echo >&2 "lxd not installed.  Aborting."; exit 1; }
lxc launch -p k8s images:centos/7 kmaster && sleep  50 && (cat kubernetes/lxd-provisioning/bootstrap-kube.sh |lxc exec kmaster bash)
lxc launch -p k8s images:centos/7 kworker1 && sleep 50 && (cat kubernetes/lxd-provisioning/bootstrap-kube.sh |lxc exec kworker1 bash)
lxc launch -p k8s images:centos/7 kworker2 && sleep 50 && (cat kubernetes/lxd-provisioning/bootstrap-kube.sh |lxc exec kworker2 bash)
}


git_clone
install_lxd
setup_k8s_cluster
