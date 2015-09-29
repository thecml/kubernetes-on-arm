#!/bin/bash

# Catch errors
trap 'exit' ERR

PKGS_TO_INSTALL="docker git"
KUBERNETES_DIR=/etc/kubernetes
KUBERNETES_CONFIG=$KUBERNETES_DIR/k8s.conf
PROJECT_SOURCE=$KUBERNETES_DIR/source
K8S_PREFIX="kubernetesonarm"
REQUIRED_MASTER_IMAGES=("$K8S_PREFIX/flannel $K8S_PREFIX/etcd $K8S_PREFIX/hyperkube $K8S_PREFIX/pause")
REQUIRED_WORKER_IMAGES=("$K8S_PREFIX/flannel $K8S_PREFIX/hyperkube $K8S_PREFIX/pause")


usage(){
	cat <<EOF
Welcome to kube-config!

With this utility, you can setup kubernetes on ARM!

Usage: 
	kube-config install - Installs docker and makes your board ready for kubernetes

	kube-config build-k8s - Build the Kubernetes images locally 
	kube-config build [image] - Build an image, which is included in the kubernetes-on-arm repository

	kube-config enable-master - Enable the master services and then kubernetes is ready to use
	kube-config enable-worker - Enable the worker services and then kubernetes has a new node

	kube-config disable-k8s - Disable Kubernetes

	kube-config info - Outputs some version information and info about your board and Kubernetes

EOF
}




install(){


	#echo "Updating the system..."
	# Systemd 226 can't be used, do not update the system
	pacman -Syy 

	echo "Now were going to install some packages"
	pacman -S $PKGS_TO_INSTALL --noconfirm

	# Create a symlink to the dropin location, so docker will use overlay
	dropins-enable-overlay

	
	# Enable the system-docker service and restart both
	systemctl enable system-docker docker
	systemctl restart system-docker docker

	echo "Set the timezone"
	if [[ -z $TIMEZONE ]]; then
		read -p "What timezone should be set? Defaults to Europe/Helsinki. " timezoneanswer

		# Defaults to Helsinki
		if [[ -z $timezoneanswer ]]; then
			timedatectl set-timezone Europe/Helsinki
		else
			timedatectl set-timezone $timezoneanswer
		fi
		
	else
		timedatectl set-timezone $TIMEZONE
	fi

	# Has the user explicitely specified it? If not, ask.
	if [[ -z $SWAP ]]; then
		read -p "Do you want to create an 1GB swapfile (useful for compiling)? [Y/n] " swapanswer
		
		case $swapanswer in
			[yY]*)
				swap;;
		esac
	elif [[ $SWAP = 1 ]]; then
		swap
	fi


	# Only set if its specified
	if [[ -z $NEW_HOSTNAME ]]; then
		read -p "What hostname do you want? Defaults to kubepi. " hostnameanswer

		# Defaults to kubepi
		if [[ -z $hostnameanswer ]]; then
			hostnamectl set-hostname kubepi
		else
			hostnamectl set-hostname $hostnameanswer
		fi
		
	else
		hostnamectl set-hostname $NEW_HOSTNAME
	fi
	if [[ -z $REBOOT ]]; then
		read -p "Do you want to reboot now? A reboot is required for Docker to function. [Y/n] " rebootanswer

		case $rebootanswer in
			[yY]*)
				reboot;;
		esac
	else [[ $REBOOT = 1 ]]
		reboot
	fi
}

swap(){
	echo "Make an 1GB swapfile, NOTE: it takes up precious sd card space"

	# Check that the swapfile doesn't already exist
	if [[ ! -f /swapfile ]]; then

		# Make 1GB swap
		dd if=/dev/zero of=/swapfile bs=1M count=1024

		# Enable it with right permissions
		mkswap /swapfile
		chmod 600 /swapfile
		swapon /swapfile

		# And recreate it on every boot
		cat >> /etc/fstab <<EOF
/swapfile  none  swap  defaults  0  0
EOF
	fi
}

build(){
	/etc/kubernetes/source/images/build.sh "$@"
}

# Remove all docker dropins. They are symlinks, so it doesn't matter
dropins-clean(){
	mkdir -p /usr/lib/systemd/system/docker.service.d/
	rm -f /usr/lib/systemd/system/docker.service.d/*.conf
}

dropins-enable(){
	systemctl daemon-reload
	systemctl restart docker
}

# Make a symlink from the config file to the dropin location
dropins-enable-overlay(){
	dropins-clean
	ln -s $KUBERNETES_DIR/dynamic-dropins/docker-overlay.conf /usr/lib/systemd/system/docker.service.d/
	dropins-enable
}

# Make a symlink from the config file to the dropin location
dropins-enable-flannel(){
	dropins-clean
	ln -s $KUBERNETES_DIR/dynamic-dropins/docker-flannel.conf /usr/lib/systemd/system/docker.service.d/
	dropins-enable
}

require-images(){

	# Check that everyone exists or fail fast
	for IMAGE in "$@"; do
		if [[ -z $(docker images | grep "$IMAGE") ]]; then
			echo "Error: Can't spin up Kubernetes without these images: $@"
			exit 1
		fi
	done
}

# Load the images which is necessary to system-docker 
load-to-system-docker(){
	# If they doesn't exist, load them from docker
	if [[ -z $(docker -H unix:///var/run/system-docker.sock images | grep "$1") ]]; then
		echo "Copying $1 to system-docker"
		docker save $1 | docker -H unix:///var/run/system-docker.sock load
	fi
}

start-master(){

	# Require these images to be present
	require-images ${REQUIRED_MASTER_IMAGES[@]}

	# Say that our master is on this board
	echo "K8S_MASTER_IP=127.0.0.1" > $KUBERNETES_CONFIG

	# Load these master images to system-docker
	load-to-system-docker $K8S_PREFIX/etcd
	load-to-system-docker $K8S_PREFIX/flannel

	# Enable and start our bootstrap services
	systemctl enable etcd flannel
	systemctl start etcd flannel

	# Create a symlink to the dropin location, so docker will use flannel
	dropins-enable-flannel

	# Enable these master services
	systemctl enable k8s-master
	systemctl start k8s-master
}

start-worker(){

	# Check if we have a connection
	if [[ $(checkformaster) != "OK" ]]; then

		# Ask for the ip
		read -p "What is the master ip? It isn't specified or reachable at the moment." masteripanswer

		# Required
		if [[ -z $masteripanswer ]]; then
			echo "Kubernetes Master IP is required. Exiting..."
			exit 1
		else
			echo "K8S_MASTER_IP=$masteripanswer" > $KUBERNETES_CONFIG
		fi

		# Check again and fail if it's not working now either
		if [[ $(checkformaster) != "OK" ]]; then
			echo "The master ip you provided isn't reachable. Exiting..."
		fi
	fi

	require-images ${REQUIRED_WORKER_IMAGES[@]}

	# Load the images which is necessary to system-docker
	load-to-system-docker $K8S_PREFIX/flannel

	# Enable and start our bootstrap services
	systemctl enable flannel
	systemctl start flannel

	# Create a symlink to the dropin location, so docker will use flannel
	dropins-enable-flannel

	# Enable these minion services
	systemctl enable k8s-worker
	systemctl start k8s-worker
}

disable(){
	systemctl stop flannel etcd k8s-master k8s-worker
	systemctl disable flannel etcd k8s-master k8s-worker
	
	dropins-clean

	systemctl restart docker
}

checkformaster(){

	# Is the config file there? Then source it
	if [[ -f $KUBERNETES_CONFIG ]]; then
		source $KUBERNETES_CONFIG

		# If ping doesn't return unknown, its OK
		if [[ -z $(ping -c1 $K8S_MASTER_IP | grep unknown) ]]; then
			echo "OK"
		fi
	fi
}

remove-etcd-datadir(){
	rm -r /var/lib/etcd
}

version(){
	echo "Architecture: $(uname -m)" 

	echo "Processors:"
	cat /proc/cpuinfo | grep "model name"

	echo "RAM Memory: $(free -m | grep Mem | awk '{print $2}') MiB"
	echo "Used RAM Memory: $(free -m | grep Mem | awk '{print $3}') MiB"
	echo "Kernel: $(uname) $(uname -r | grep -o "[0-9.]*" | grep "[.]")"
	
	# Is docker running?
    docker ps 2> /dev/null 1> /dev/null
    if [ "$?" == "0" ]; then

    	# Do we have hyperkube? Then output version
      	if [[ ! -z $(docker images | grep $K8S_PREFIX/hyperkube) ]]; then
      		docker run --rm $K8S_PREFIX/hyperkube /hyperkube --version
      	fi
    fi
}


if [[ -z $1 ]]; then
        usage
        exit
fi

case $1 in
        'install')
                install;;
        'build')
				build "$@";;
        'build-k8s')
                build ${REQUIRED_MASTER_IMAGES[@]};;
        'enable-master')
                start-master;;
        'enable-worker')
                start-worker;;
       	'delete-k8s-data')
				remove-etcd-datadir;;
       	'disable-k8s')
				disable;;
        'version')
                version;;
        'info')
				version;;
esac