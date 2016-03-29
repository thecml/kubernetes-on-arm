## Kubernetes on ARM addons

How to enable/disable:
``` 
kube-config enable-addon [addon-name]
kube-config disable-addon [addon-name]
```

All these addons live in the `kube-system` namespace.
Check it out:
```
kubectl --namespace=kube-system get po,rc,svc,ep

kubectl cluster-info
```

### DNS

The official `amd64` DNS addon is here: https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns

### Registry

The official `amd64` registry addon is here: https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/registry

### Dashboard

The official `amd64` dashboard addon is here: https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dashboard

### Loadbalancer

The official `amd64` service-loadbalancer addon is here: https://github.com/kubernetes/contrib/tree/master/service-loadbalancer

### Heapster

The official `amd64` heapster addon is here: https://github.com/kubernetes/heapster/tree/master/deploy/kube-config/influxdb

### Sleep

Just two pods for testing

If you want to test out some kubernetes settings like DNS, this addon is very handy.
Starts up two containers, resin/rpi-raspbian and luxas/alpine. They both sleep for one hour and then restarts forever.

Example use:
```
kubectl exec -it alpine-sleep /bin/sh

kubectl exec -it raspbian-sleep /bin/bash

kubectl exec -it alpine-sleep -- nslookup kubernetes.default.svc.cluster.local
```
