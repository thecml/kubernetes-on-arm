#!/bin/bash

# Compile binaries and docker images

# Catch errors
trap 'exit' ERR


echo "Again, check how much free space we have on our system, for later comparision"
df -h

# Now we are in the current dir
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Load the images which is necessary
docker save k8s/etcd | system-docker load
docker save k8s/flannel | system-docker load

# Get etcd container hash
ETCD=$(system-docker run -d --net=host k8s/etcd /usr/bin/etcd --addr=127.0.0.1:4001 --bind-addr=0.0.0.0:4001 --data-dir=/var/etcd/data)

# Set flannel subnet
system-docker run --rm --net=host k8s/etcd etcdctl set /coreos.com/network/config '{ "Network": "10.1.0.0/16" }'

# Stop docker 
systemctl stop docker.service docker.socket

# Start flannel
FLANNEL=$(system-docker run -d --net=host --privileged -v /dev/net:/dev/net k8s/flannel /flanneld)

# Get the settings
system-docker cp $FLANNEL:/run/flannel/subnet.env .

# Source those settings
source subnet.env

# Modify docker settings
sed -e "s@-s overlay@-s overlay --bip=$FLANNEL_SUBNET --mtu=$FLANNEL_MTU@" -i /usr/lib/systemd/system/docker.service

# Bring the docker bridge down
ifconfig docker0 down

# And delete it
brctl delbr docker0

# Reload systemd
systemctl daemon-reload

# Start it again
systemctl start docker

# Start k8s master components
docker run -d --net=host  -v /var/run/docker.sock:/var/run/docker.sock  k8s/hyperkube /hyperkube kubelet --pod_infra_container_image="k8s/pause" --api-servers=http://localhost:8080 --v=2 --address=0.0.0.0 --enable-server --hostname-override=master --config=/etc/kubernetes/manifests-multi


# OK, Now the k8s cluster should be ready


