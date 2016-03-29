### Docker image of the [coreos/etcd](https://github.com/coreos/etcd) project.

Built for ARM.
Just 18 MB.
[Build script](https://github.com/luxas/kubernetes-on-arm/blob/master/images/kubernetesonarm/build/inbuild.sh)
Base image: [luxas/alpine](https://hub.docker.com/r/luxas/alpine)
The [Dockerfile](https://github.com/luxas/kubernetes-on-arm/blob/master/images/kubernetesonarm/etcd/Dockerfile)
No arguments are needed for it to work.


Description: 
Used in the Kubernetes project as data store for the Kubernetes apiserver.
Includes both `etcd` and `etcdctl`.
