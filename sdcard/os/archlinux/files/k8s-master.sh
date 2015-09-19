#!/bin/bash

# Catch errors
trap 'exit' ERR

# Now we are in the current dir
cd "$( dirname "${BASH_SOURCE[0]}" )"

mkdir -p /var/lib/luxcloud/scripts


### REQUIRED IMAGES FOR THIS TO WORK ###

# List them here, luxas/registry is not 100% necessary but could be listed anyway
REQUIRED_IMAGES=("k8s/flannel k8s/etcd k8s/hyperkube k8s/pause luxas/registry")

# Check that everyone exists or fail fast
for IMAGE in ${REQUIRED_IMAGES[@]}; do
	if [[ -z $(docker images | grep "$IMAGE") ]]; then
		echo "Error: Can't spin up the Kubernetes master service without these images: ${REQUIRED_IMAGES[@]}"
		exit 1
	fi
done


# Load the images which is necessary to system-docker 
if [[ -z $(docker images | grep "k8s/etcd") ]]; then
	docker save k8s/etcd | docker -H unix:///var/run/system-docker.sock load
fi
if [[ -z $(docker images | grep "k8s/flannel") ]]; then
	docker save k8s/flannel | docker -H unix:///var/run/system-docker.sock load
fi


### FILES ###

# Notice: the files comes in execution order, first etcd, then flannel, etc.

# The file for etcd. Things that could cause problems is when the /var/etcd/data is already populated, and in some situations with WRONG data
# Solution:
# rm -r /var/etcd/data
cat > /usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Master Data Store for Kubernetes Apiserver
After=system-docker.service

[Service]
ExecStartPre=-/usr/bin/docker -H unix:///var/run/system-docker.sock kill etcd-k8s
ExecStartPre=-/usr/bin/docker -H unix:///var/run/system-docker.sock rm etcd-k8s
ExecStartPre=-/usr/bin/mkdir -p /var/lib/etcd
ExecStart=/usr/bin/docker -H unix:///var/run/system-docker.sock run --net=host --name=etcd-k8s -v /var/lib/etcd:/var/etcd/data k8s/etcd
ExecStartPost=/usr/bin/docker -H unix:///var/run/system-docker.sock run --rm --net=host k8s/etcd etcdctl set /coreos.com/network/config '{ "Network": "10.1.0.0/16" }'
ExecStop=/usr/bin/docker -H unix:///var/run/system-docker.sock stop etcd-k8s

[Install]
WantedBy=multi-user.target
EOF

# Here is the flannel service, always begin with new data
# The /flanneld end is deprecated
cat > /usr/lib/systemd/system/flannel.service <<EOF
[Unit]
Description=Flannel Overlay Network for Kubernetes
After=etcd.service

[Service]
ExecStartPre=-/usr/bin/docker -H unix:///var/run/system-docker.sock kill flannel-k8s
ExecStartPre=-/usr/bin/docker -H unix:///var/run/system-docker.sock rm flannel-k8s
ExecStartPre=-/usr/bin/rm -rf /var/lib/flannel
ExecStartPre=-/usr/bin/mkdir -p /var/lib/flannel
ExecStart=/usr/bin/docker -H unix:///var/run/system-docker.sock run --name=flannel-k8s --net=host --privileged -v /dev/net:/dev/net -v /var/lib/flannel:/run/flannel k8s/flannel /flanneld
ExecStop=/usr/bin/docker -H unix:///var/run/system-docker.sock stop flannel-k8s

[Install]
WantedBy=multi-user.target
EOF

# This is how the Docker daemon should be started
# Notice the 'EOF', that means literally. We want it that way.
cat > /etc/systemd/system/docker.service.d/luxcloud.conf <<'EOF'
[Unit]
After=flannel.service

[Service]
EnvironmentFile=/var/lib/flannel/subnet.env
ExecStart=
ExecStart=/usr/bin/docker -d -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 -s overlay --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} --insecure-registry=localhost:5000
EOF


# Make a wrapper for starting up k8s
cat > /var/lib/luxcloud/scripts/spin-up-k8s.sh <<'EOF'
#!/bin/bash
if [[ $1 == "master" ]]; then
	exec docker run --name=master-k8s --net=host -v /var/run/docker.sock:/var/run/docker.sock k8s/hyperkube /hyperkube kubelet --pod_infra_container_image="k8s/pause" --api-servers=http://localhost:8080 --v=2 --address=0.0.0.0 --enable-server --hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}') --config=/etc/kubernetes/manifests-multi
else
	source /var/lib/luxcloud/config.sh
	exec docker run --name=minion-k8s --net=host -v /var/run/docker.sock:/var/run/docker.sock  k8s/hyperkube /hyperkube kubelet --pod_infra_container_image="k8s/pause" --api-servers=http://${MASTER_IP}:8080 --v=2 --address=127.0.0.1 --enable-server --hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}')
fi
EOF

chmod +x /var/lib/luxcloud/scripts/spin-up-k8s.sh

# Again, this should be taken literally, get our ip and use that as our node id
# Starts our hyperkube binary, which turns up the other master components
cat > /usr/lib/systemd/system/master-k8s.service <<EOF
[Unit]
Description=The Master Components for Kubernetes
After=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill master-k8s
ExecStartPre=-/usr/bin/docker rm master-k8s
ExecStart=/var/lib/luxcloud/scripts/spin-up-k8s.sh master
ExecStop=/usr/bin/docker stop master-k8s

[Install]
WantedBy=multi-user.target
EOF

# Bring up our registry
cat > /usr/lib/systemd/system/registry.service <<EOF
[Unit]
Description=The Docker Image Registry
After=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill registry
ExecStartPre=-/usr/bin/docker rm registry
ExecStartPre=-/usr/bin/mkdir -p /var/lib/registry
ExecStart=/usr/bin/docker run --name=registry --net=host -v /var/lib/registry:/var/lib/registry luxas/registry
ExecStop=/usr/bin/docker stop registry

[Install]
WantedBy=multi-user.target
EOF

### ENABLE PROCESS ###

# First of all, systemd would like to be noticed about our new files
systemctl daemon-reload


# Enable and start our bootstrap services
systemctl enable flannel etcd
systemctl start etcd flannel

# Shut down docker completely
systemctl stop docker.service docker.socket

# Remove the docker0 network interface
# Docker will create a new one anyway (with our new flannel settings!)
ifconfig docker0 down
brctl delbr docker0

# Bring docker up again
systemctl start docker 

# Enable these master services
systemctl enable master-k8s registry
systemctl start master-k8s registry