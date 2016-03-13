### Docker image for the [Kubernetes hyperkube](https://github.com/kubernetes/kubernetes).

Built for ARM.
125 MB.
[Build script](https://github.com/luxas/kubernetes-on-arm/blob/master/images/kubernetesonarm/build/inbuild.sh)
Base image: resin/rpi-raspbian
The [Dockerfile](https://github.com/luxas/kubernetes-on-arm/blob/master/images/kubernetesonarm/hyperkube/Dockerfile)


Description: 
The core Kubernetes image. Used in the whole Kubernetes cluster, on both master and workers.
The hyperkube is a all-in-one binary. 
It includes `apiserver`, `controller-manager`, `scheduler`, `kubelet` and `kube-proxy`.


Must be dynamically built, otherwise it will fail with this fatal error: 
```
Error: failed to create kubelet: cAdvisor is unsupported in this build
failed to create kubelet: cAdvisor is unsupported in this build
```

Examples:

```
# Start the master components in one command
docker run -d --net=host -v /var/run/docker.sock:/var/run/docker.sock kubernetesonarm/hyperkube /hyperkube kubelet --pod_infra_container_image="kubernetesonarm/pause" --api-servers=http://localhost:8080 --v=2 --address=0.0.0.0 --enable-server --hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}') --config=/etc/kubernetes/manifests-multi

# There are many parts:

# Run the image in daemon mode. All ports exposed in this image are also exposed on host. Do not use this other than for testing.
docker run -d --net=host

# Let kubelet communicate and start docker images. Important.
-v /var/run/docker.sock:/var/run/docker.sock

# Run the hyperkube binary
/hyperkube

# Say that we want to start the kubelet component, which will start the other master components
kubelet

# Required when we are on ARM. Internal image
--pod_infra_container_image="kubernetesonarm/pause"

# Specify that the apiserver should be listened at at this address. This also makes so kubelet registers the node.
--api-servers=http://localhost:8080

# Verbosity
--v=2

# The IP address for the Kubelet to serve on (port 10250). If 127.0.0.1, only locally. If 0.0.0.0 both locally and exposed to other nodes.
--address=0.0.0.0

# Enable the Kubelet's server
--enable-server

# OK, this is a hack, but when I used this, it only worked when --hostname-override was set to the node's ip address. Feel free to replace manually with the ip
--hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}')

# In which directory kubelet finds the master components configuration
--config=/etc/kubernetes/manifests-multi

# If you want a worker:
# omit the --config 
# change the --address to 127.0.0.1 (not visible to other nodes)
# change --api-server to http://${MASTER_IP}:8080


# If you want DNS:

# Specify that the DNS server will be available at internal ip 10.0.0.10
--cluster-dns=10.0.0.10 

# Our cluster DNS names ends with this string
--cluster-domain=cluster.local
```
