#!/bin/bash

#
# $1	master IP address
# $2	worker IP base
# $3	worker node count
#

echo "network interfaces:"
ifconfig

# hostname -i must return a routable address on second (non-NATed) network interface
# see 5) in http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations
#   and     https://github.com/kubernetes/kubernetes/issues/34101
sed "s/127.0.0.1.*master/$1 master/" -i /etc/hosts

# additionally, master needs to be able to resolve worker nodes by name
for i in `seq 1 $3`; do
	echo "$2$i	worker$i" >> /etc/hosts
done

echo "initializing kubernetes master..."
kubeadm init --api-advertise-addresses=$1 --token=c6bdb3.2ad6171ee91c372f

sleep 10

echo "installing weave overlay network..."
kubectl apply -f https://git.io/weave-kube

echo "tweaking kube-proxy mode..."
#
# see https://github.com/kubernetes/kubernetes/issues/34101#issuecomment-253235083
#    Note: had to remove -amd64 everywhere
#
kubectl -n kube-system get ds -l 'component=kube-proxy' -o json | jq '.items[0].spec.template.spec.containers[0].command |= .+ ["--proxy-mode=userspace"]' | kubectl apply -f - && kubectl -n kube-system delete pods -l 'component=kube-proxy'

echo "installing registry..."
kubectl apply -f /home/ubuntu/def/rc-registry.yaml
kubectl apply -f /home/ubuntu/def/svc-registry.yaml
cp /home/ubuntu/def/pod-registry-proxy.yaml /etc/kubernetes/manifests/

echo "done"
