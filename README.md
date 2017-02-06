# *Kubernetes* with *Vagrant* and `kubeadm`

## Synopsis

Sometimes, [Minikube](https://kubernetes.io/docs/getting-started-guides/minikube/) is not what you want when playing around with *Kubernetes* on your local workstation. Instead, you may want to have a cluster where the cluster nodes are *Vagrant*-controlled VMs. At least, I feel that way, and if you're like me, this project may be of interest to you. It sets up a VM for the *K8s* master, and an additional VM for every worker node. *K8s* itself is deployed vi [`kuebadm`](https://kubernetes.io/docs/getting-started-guides/kubeadm/).

## TODO

- Make node RAM size & core count configurable
- Max. number of worker nodes currently limited to 9
- Create worker nodes in parallel
- Sometimes `kubeadm` takes a long time to set up the master node (without CPU or network load). Not sure why, may depend on how the workstation is connected to the network. 


## Creating the Base Box

Before you bring up a cluster for the first time, you need to create the base image for the VMs. You only need to do this once:

```bash
cd base
./createbox
```

This will get the `ubuntu/xenial64` box from the *Hashicorp* *Atlas*, if it's not present yet, and start a VM with it. In this VM, packages are then updated, and additional packages for *Kubernetes* installed. Finally, the VM is shut down, and a base box created from it, which can now be used for running *Kubernetes* master and worker nodes. 


## Starting

### Complete Cluster

To start a *K8s* cluster in one go, do:

```bash
cd kube
./kubeup [num worker nodes] [--provider libvirt|virtualbox]
```

For individually starting master and worker nodes, see below. *Note*: For `libvirt` provider, the VM currently hangs during boot (FIXME). Default is therefore `virtualbox`.

### Master Node

```bash
cd kube
vagrant up [--provider libvirt|virtualbox]
```

### Worker Nodes

Wait a couple of minutes after starting the master, then:

```bash
cd kube
vagrant up worker{i} [--provider libvirt|virtualbox]
```

This can also be used to add nodes to the cluster later on.

### ssh

```bash
vagrant ssh master
vagrant ssh worker{i}
```


## Interacting With the Cluster

After setting up the cluster, you can run `proxy` in folder `kube` to start a proxy for the K8s API on `localhost:8001`, so you can interact with the cluster from your workstation (provided you got `kubectl` in your path), e.g.:

```bash
kubectl --server="http://127.0.0.1:8001" get nodes
```

### Registry

The setup above will also deploy a container registry in the cluster, so you can easily experiment with stuff you don't want to upload into a public registry. (Not yet verified whether this really works.) 

### System Pods

Here's what you would get after settings up a three node cluster:

```bash
kubectl --server="http://127.0.0.1:8001" get pods --namespace=kube-system

NAME                              READY     STATUS    RESTARTS   AGE
dummy-2088944543-svqp6            1/1       Running   0          1h
etcd-master                       1/1       Running   0          1h
kube-apiserver-master             1/1       Running   3          1h
kube-controller-manager-master    1/1       Running   0          1h
kube-discovery-1769846148-fjwjn   1/1       Running   0          1h
kube-dns-2924299975-vk3jj         4/4       Running   0          1h
kube-proxy-27c7p                  1/1       Running   0          1h
kube-proxy-fbxpl                  1/1       Running   0          1h
kube-proxy-gtbn5                  1/1       Running   0          1h
kube-proxy-pfmx0                  1/1       Running   0          1h
kube-registry-proxy-master        1/1       Running   0          1h
kube-registry-proxy-worker1       1/1       Running   0          1h
kube-registry-proxy-worker2       1/1       Running   0          1h
kube-registry-proxy-worker3       1/1       Running   0          1h
kube-registry-v0-g9x0f            1/1       Running   0          1h
kube-scheduler-master             1/1       Running   0          1h
weave-net-57cg8                   2/2       Running   0          1h
weave-net-7mwbw                   2/2       Running   0          1h
weave-net-h69g3                   2/2       Running   0          1h
weave-net-l1qd8                   2/2       Running   1          1h
```

## Suspending Cluster

Using `vagrant suspend`, you can actually suspend the whole cluster. You can bring it up again in this way:

```bash
vagrant up --parallel master worker1 worker2 ... worker{n}
```

This is much faster than starting from scratch and may be interesting for demo scenarios.


## Tearing Down

To tear down the whole cluster, do

```bash
cd kube
./kubedown
```

To destroy a particular worker node:

```bash
cd kube
./kubedown {worker number}
```

*Note*: If you destroy a worker node via `vagrant destroy worker{i}`, it will not be unregistered in the master node.
