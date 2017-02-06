#!/bin/bash

apt-get update
apt-get upgrade -y

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
  deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y selinux-utils docker.io kubelet kubeadm kubectl kubernetes-cni jq

setenforce 0

sleep 60

reboot
