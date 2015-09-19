#!/bin/bash

# Catch errors
trap 'exit' ERR

# Now we are in the current dir
cd "$( dirname "${BASH_SOURCE[0]}" )"

mkdir -p /var/lib/luxcloud/scripts

### ENSURE WE HAVE MASTER_IP ###

# Check if our config exists
if [[ ! -d /var/lib/luxcloud || ! -f /var/lib/luxcloud/config.sh ]]; then
	read -p "Where is you master? Specify MASTER_IP." master
	mkdir /var/lib/luxcloud
	echo "MASTER_IP=$master" >> /var/lib/luxcloud/config.sh
fi

source /var/lib/luxcloud/config.sh

# If ping returns unknown
if [[ ! -z $(ping -c1 $MASTER_IP | grep unknown) ]]
	echo "MASTER_IP (value: $MASTER_IP) is not reachable. Exiting."
	exit 1
fi


### REQUIRED IMAGES FOR THIS TO WORK ###

# List them here
REQUIRED_IMAGES=("k8s/flannel k8s/hyperkube k8s/pause")

# Check that everyone exists or fail fast
for IMAGE in ${REQUIRED_IMAGES[@]}; do
	if [[ -z $(docker images | grep "$IMAGE") ]]; then
		echo "Error: Can't spin up the Kubernetes master service without these images: ${REQUIRED_IMAGES[@]}"
		exit 1
	fi
done


# Load the flannel image, which is necessary, to system-docker 
if [[ -z $(docker images | grep "k8s/flannel") ]]; then
	docker save k8s/flannel | docker -H unix:///var/run/system-docker.sock load
fi



### FILES ###

# Notice: the files comes in execution order

# Here is the flannel service, always begin with new data
cat > /usr/lib/systemd/system/flannel.service <<EOF
[Unit]
Description=Flannel Overlay Network for Kubernetes
After=etcd.service

[Service]
EnvironmentFile=/var/lib/luxcloud/config.sh
ExecStartPre=-/usr/bin/docker -H unix:///var/run/system-docker.sock kill flannel-k8s
ExecStartPre=-/usr/bin/docker -H unix:///var/run/system-docker.sock rm flannel-k8s
ExecStartPre=-/usr/bin/rm -rf /var/lib/flannel
ExecStartPre=-/usr/bin/mkdir -p /var/lib/flannel
ExecStart=/usr/bin/docker -H unix:///var/run/system-docker.sock run --name=flannel-k8s --net=host --privileged -v /dev/net:/dev/net -v /var/lib/flannel:/run/flannel k8s/flannel /flanneld --etcd-endpoints=http://${MASTER_IP}:4001
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
ExecStart=/usr/bin/docker -d -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 -s overlay --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}
EOF


# Make a wrapper for starting up k8s
cat > /var/lib/luxcloud/scripts/spin-up-k8s.sh <<EOF
#!/bin/bash
if [[ $1 == "master" ]]; then
	exec docker run --name=master-k8s --net=host -v /var/run/docker.sock:/var/run/docker.sock k8s/hyperkube /hyperkube kubelet --pod_infra_container_image="k8s/pause" --api-servers=http://localhost:8080 --v=2 --address=0.0.0.0 --enable-server --hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}') --config=/etc/kubernetes/manifests-multi
else
	source /var/lib/luxcloud/config.sh
	exec docker run --name=minion-k8s --net=host -v /var/run/docker.sock:/var/run/docker.sock  k8s/hyperkube /hyperkube kubelet --pod_infra_container_image="k8s/pause" --api-servers=http://${MASTER_IP}:8080 --v=2 --address=127.0.0.1 --enable-server --hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}')
fi
EOF

chmod +x /var/lib/luxcloud/scripts/spin-up-k8s.sh

# Spin up our minion k8s, with our ip as our name
# We want this file be written literally
cat > /usr/lib/systemd/system/minion-k8s.service <<'EOF'
[Unit]
Description=The Minion Components for Kubernetes
After=docker.service

[Service]
EnvironmentFile=/var/lib/luxcloud/config.sh
ExecStartPre=-/usr/bin/docker kill minion-k8s minion-k8s-proxy
ExecStartPre=-/usr/bin/docker rm minion-k8s minion-k8s-proxy
ExecStart=/var/lib/luxcloud/scripts/spin-up-k8s.sh
ExecStartPost=/usr/bin/docker run --name=minion-k8s-proxy --net=host --privileged k8s/hyperkube /hyperkube proxy --master=http://${MASTER_IP}:8080 --v=2
ExecStop=/usr/bin/docker stop minion-k8s minion-k8s-proxy

[Install]
WantedBy=multi-user.target
EOF


### ENABLE PROCESS ###

# First of all, systemd would like to be noticed about our new files
systemctl daemon-reload

# Enable and start our bootstrap services
systemctl enable flannel
systemctl start flannel


# Shut down docker completely
systemctl stop docker.service docker.socket

# Remove the docker0 network interface
# Docker will create a new one anyway (with our new flannel settings!)
ifconfig docker0 down
brctl delbr docker0

# Bring docker up again
systemctl start docker


# Enable the minion service
systemctl enable minion-k8s
systemctl start minion-k8s