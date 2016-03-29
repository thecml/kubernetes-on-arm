### (Optional) Build the Docker images for ARM

With this script, the required docker images are built, then the Kubernetes binaries and last, the Kubernetes images used when running.

```bash

# Build all required images
kube-config build-images

# These scripts will run approximately 45 min on a Raspberry Pi 2
# Grab yourself a coffee during the time!
```

The script will produce these Docker images: 
 - luxas/alpine: Is a Alpine Linux image. Only 8 MB. Based on `mini-containers/base` source.
 - luxas/go: Is a Golang image, which is used for building repositories on ARM.
 - kubernetesonarm/build: This image downloads all source code and builds it for ARM.

These core images are used in the cluster:
 - kubernetesonarm/etcd: `etcd` is the data store for Kubernetes. Used only on master. [Docs](images/kubernetesonarm/etcd/README.md)
 - kubernetesonarm/flannel: `flannel` creates the Kubernetes overlay network. [Docs](images/kubernetesonarm/flannel/README.md)
 - kubernetesonarm/hyperkube: This is the core Kubernetes image. This one powers your Kubernetes cluster. [Docs](images/kubernetesonarm/hyperkube/README.md)
 - kubernetesonarm/pause: `pause` is a image Kubernetes uses internally. [Docs](images/kubernetesonarm/pause/README.md)
