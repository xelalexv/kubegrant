#!/bin/bash

#
# $1	master IP address
# $2	worker node name
# $3	worker IP address
#

# hostname -i must return a routable address on second (non-NATed) network interface
# see 7) in http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations
#   and     https://github.com/kubernetes/kubernetes/issues/34101
sed "s/127.0.0.1.*$2/$3 $2/" -i /etc/hosts

echo "joing cluster..."
kubeadm join --token=c6bdb3.2ad6171ee91c372f $1

echo "installing registry proxy..."
cp /home/ubuntu/def/pod-registry-proxy.yaml /etc/kubernetes/manifests/

echo "done"
