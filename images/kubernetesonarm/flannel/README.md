### Docker image of the [coreos/flannel](https://github.com/coreos/flannel) project.

Built for ARM.
90 MB
[Build script](https://github.com/luxas/kubernetes-on-arm/blob/master/images/kubernetesonarm/build/inbuild.sh)
Base image: resin/rpi-raspbian
The [Dockerfile](https://github.com/luxas/kubernetes-on-arm/blob/master/images/kubernetesonarm/flannel/Dockerfile)
No arguments are needed for it to work.


Description: 
Used in the Kubernetes project as overlay network provider for Kubernetes.
Includes `flannel` and `iptables`.