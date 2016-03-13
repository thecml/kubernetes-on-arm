### Docker image for the [Kubernetes pod infra container](https://github.com/kubernetes/kubernetes/tree/master/build/pause).

Built for ARM.
Just 227 kB!
[Build script](https://github.com/luxas/kubernetes-on-arm/blob/master/images/kubernetesonarm/build/inbuild.sh)
Base image: none (scratch)
The [Dockerfile](https://github.com/luxas/kubernetes-on-arm/blob/master/images/kubernetesonarm/pause/Dockerfile)
No arguments are needed for it to work. It just sleeps.


Description: 
Used for internal purposes in the Kubernetes cluster.
