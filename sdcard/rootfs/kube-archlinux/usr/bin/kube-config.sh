#!/bin/bash

# Catch errors
trap 'exit' ERR

PKGS_TO_INSTALL="docker git"
KUBERNETES_DIR=/etc/kubernetes
ADDONS_DIR=$KUBERNETES_DIR/addons
KUBERNETES_CONFIG=$KUBERNETES_DIR/k8s.conf
PROJECT_SOURCE=$KUBERNETES_DIR/source
K8S_PREFIX="kubernetesonarm"

DOCKER_DROPIN_DIR="/usr/lib/systemd/system/docker.service.d/"

# The images that are required
REQUIRED_MASTER_IMAGES=("$K8S_PREFIX/flannel $K8S_PREFIX/etcd $K8S_PREFIX/hyperkube $K8S_PREFIX/pause")
REQUIRED_WORKER_IMAGES=("$K8S_PREFIX/flannel $K8S_PREFIX/hyperkube $K8S_PREFIX/pause")
REQUIRED_ADDON_IMAGES=("$K8S_PREFIX/skydns $K8S_PREFIX/kube2sky $K8S_PREFIX/exechealthz $K8S_PREFIX/registry")

DEFAULT_TIMEZONE="Europe/Helsinki"
DEFAULT_HOSTNAME="kubepi"

LATEST_DOWNLOAD_RELEASE="v0.6.0"

# If the config doesn't exist, create
if [[ ! -f $KUBERNETES_CONFIG ]]; then
	echo "K8S_MASTER_IP=127.0.0.1" > $KUBERNETES_CONFIG
fi


# Source the config
source $KUBERNETES_CONFIG

usage(){
	cat <<EOF
Welcome to kube-config!

With this utility, you can setup Kubernetes on ARM!

Usage: 
	kube-config install - Installs docker and makes your board ready for kubernetes
	kube-config upgrade - Upgrade current operating system packages to latest version.

	kube-config build-images - Build the Kubernetes images locally
	kube-config build-addons - Build the Kubernetes addon images locally
	kube-config build [image] - Build an image, which is included in the kubernetes-on-arm repository
		- Options with the luxas prefix:
			- luxas/alpine: My alpine base image
			- luxas/bench: Benchmark your ARM board compared to a Raspberry Pi 1. Based on Roy Longbottoms Benchmarks
			- luxas/go: My Golang image
			- luxas/nginx-test: Simple nginx image based on alpine. Used mostly for testing.
			- luxas/nodejs: node.js image based on alpine.
			- luxas/raspbian: A Raspbian base image. Based on resin/rpi-raspbian.

	kube-config enable-master - Enable the master services and then kubernetes is ready to use
		- FYI, etcd data will be stored in the /var/lib/kubernetes/etcd directory. Backup that directory if you have important data.
	kube-config enable-worker - Enable the worker services and then kubernetes has a new node
	kube-config enable-addon [addon] - Enable an addon
		- Currently defined addons
				- dns: Makes all services accessible via DNS
				- registry: Makes a central docker registry
				- loadbalancer: A loadbalancer that exposes services to the outside world. Coming soon...
				- sleep: A debug addon. Starts two containers: luxas/alpine and luxas/raspbian.

	kube-config disable-node - Disable Kubernetes on this node, reverting the enable actions, useful if something went wrong
	kube-config disable - Synonym to disable-node
	kube-config disable-addon [addon] - Disable an addon, not the whole cluster
	
	kube-config delete-data - Clean the /var/lib/kubernetes and /var/lib/kubelet directories, where all master data is stored

	kube-config info - Outputs some version information and info about your board and Kubernetes
	kube-config help - Display this help
EOF
}


install(){

	# Source the commands, e.g. os_install, os_upgrade, post_install
	if [[ -f $KUBERNETES_DIR/dynamic-env/env.conf ]]; then
		source $KUBERNETES_DIR/dynamic-env/env.conf
	elif [[ -z $MACHINE || -z $OS ]]; then
		read -p "Which board is this running on? Options: [rpi, rpi-2, cubietruck, parallella]. " MACHINE
		read -p "Which OS do you have? Options: [archlinux]. " OS

		# Write the info to the file
		cat > $KUBERNETES_DIR/dynamic-env/env.conf <<EOF
OS=$OS
MACHINE=$MACHINE
EOF
	fi

	# Source the files
	source $KUBERNETES_DIR/dynamic-env/$MACHINE.sh
	source $KUBERNETES_DIR/dynamic-env/$OS.sh

	# If we have a external command file, use it
	if [[ $(type -t os_install) == "function" ]]; then

		echo "Installing required packages for this OS"
		os_install $PKGS_TO_INSTALL
	else
		# Fallback on archlinux for the moment
		echo "Updating the system..."
		pacman -Syu --noconfirm

		echo "Now were going to install some packages"
		pacman -S $PKGS_TO_INSTALL --noconfirm --needed
	fi

	

	# Enable the docker and system-docker service
	# But don't start them now, it won't work.
	systemctl enable system-docker docker
	systemctl stop system-docker docker

	echo "Downloading prebuilt binaries. It is possible to build them manually later."

	# Download latest binaries, now we have them in $PATH
	mkdir -p /etc/kubernetes/source/images/kubernetesonarm/_bin/latest
	curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/$LATEST_DOWNLOAD_RELEASE/binaries.tar.gz | tar -xz -C $KUBERNETES_DIR/binaries

	if [[  $(type -t post_install) == "function" ]]; then
		echo "Doing some custom work specific to this board"
		post_install
	fi


	if [[ -z $TIMEZONE ]]; then
		read -p "Which timezone should be set? Defaults to $DEFAULT_TIMEZONE. " timezoneanswer

		# Defaults to Helsinki
		if [[ -z $timezoneanswer ]]; then
			timedatectl set-timezone $DEFAULT_TIMEZONE
		else
			timedatectl set-timezone $timezoneanswer
		fi
		
	else
		timedatectl set-timezone $TIMEZONE
	fi

	# Has the user explicitely specified it? If not, ask.
	if [[ -z $SWAP ]]; then
		read -p "Do you want to create an 1GB swapfile (required for compiling)? n is default [y/N] " swapanswer
		
		case $swapanswer in
			[yY]*)
				swap;;
		esac
	elif [[ $SWAP == 1 || $SWAP == "y" || $SWAP == "Y" ]]; then
		swap
	fi


	# Only set if its specified
	if [[ -z $NEW_HOSTNAME ]]; then
		read -p "What hostname do you want? Defaults to $DEFAULT_HOSTNAME. " hostnameanswer

		# Defaults to kubepi
		if [[ -z $hostnameanswer ]]; then
			hostnamectl set-hostname $DEFAULT_HOSTNAME
		else
			hostnamectl set-hostname $hostnameanswer
		fi
		
	else
		hostnamectl set-hostname $NEW_HOSTNAME
	fi


	# Reboot?
	if [[ -z $REBOOT ]]; then
		read -p "Do you want to reboot now? A reboot is required for Docker to function. Y is default. [Y/n] " rebootanswer

		case $rebootanswer in
			[nN]*)
				echo "Done.";;
			*)
				reboot;;
		esac
	elif [[ $REBOOT == 1 || $REBOOT == "y" || $REBOOT == "Y" ]]; then
		reboot
	fi
}

upgrade(){
	echo "Upgrading the system"
	if [[ $(type -t os_upgrade) == "function" ]]; then
		os_upgrade
	else
		pacman -Syu --noconfirm
	fi
}

swap(){
	echo "Makes an 1GB swapfile, NOTE: it takes up precious SD Card space"

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

# This is faster than Docker Hub
download_imgs(){
	# Approx. 10 secs faster than doing this with two commands, now ~160 secs
	echo "Downloading Kubernetes docker images from Github"
	curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/$LATEST_DOWNLOAD_RELEASE/images.tar.gz | gzip -dc | docker load
	# v0.5.5 curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/$LATEST_DOWNLOAD_RELEASE/images.tar.gz | tar -xz -O | docker load
}

### --------------------------------- HELPERS -----------------------------------

# A forwarder to the build script in the repo
build(){
	$PROJECT_SOURCE/images/build.sh "$@"
}

# Remove all docker dropins. They are symlinks, so it doesn't matter
dropins-clean(){
	mkdir -p $DOCKER_DROPIN_DIR
	rm -f $DOCKER_DROPIN_DIR/*.conf
}

dropins-enable(){
	systemctl daemon-reload
	systemctl restart docker
}

# Make a symlink from the config file to the dropin location
dropins-enable-overlay(){
	dropins-clean
	ln -s $KUBERNETES_DIR/dropins/docker-overlay.conf $DOCKER_DROPIN_DIR
	dropins-enable
}

# Make a symlink from the config file to the dropin location
dropins-enable-flannel(){
	dropins-clean
	ln -s $KUBERNETES_DIR/dropins/docker-flannel.conf $DOCKER_DROPIN_DIR
	dropins-enable
}

require-images(){
	local FAIL=0

	# Loop every image, check if it exists
	for IMAGE in "$@"; do
		if [[ -z $(docker images | grep "$IMAGE") ]]; then

			# If it doesn't exist, try to pull
			echo "Pulling $IMAGE from Docker Hub"
			docker pull $IMAGE
			
			if [[ -z $(docker images | grep "$IMAGE") ]]; then

				echo "Pull failed. Try to pull this image yourself: $IMAGE"
				FAIL=1
			fi
		fi
	done

	if [[ $FAIL == 1 ]]; then
		echo "One or more images failed to pull. Exiting...";
		exit 1
	fi
}

# Load an image to system-docker
load-to-system-docker(){
	# If they doesn't exist, load them from main docker
	if [[ -z $(docker -H unix:///var/run/system-docker.sock images | grep "$1") ]]; then
		echo "Copying $1 to system-docker"
		docker save $1 | docker -H unix:///var/run/system-docker.sock load
	fi
}

get-node-type(){
	local workerstate=$(systemctl is-active k8s-worker)
	local masterstate=$(systemctl is-active k8s-master)
	if [[ workerstate == "active" ]]; then
		echo "worker";
	elif [[ masterstate == "active" ]]; then
		echo "master";
	else
		echo "";
	fi
}

# Is kubernetes enabled?
is-active(){
	if [[ get-node-type != "" ]]; then
		return 1;
	else 
		return 0;
	fi
}

checkformaster(){
	# If ping doesn't return unknown, its OK
	if [[ -z $(ping -c1 $K8S_MASTER_IP | grep unknown) ]]; then
		echo "OK"
	fi
}

# ----------------------------------------------- MAIN -------------------------------------------

start-master(){

	# Disable some (already running?) services
	echo "Disabling k8s if it is running"
	disable >/dev/null
	sleep 1

	# Require these images to be present
	echo "Checks so all images are present"

	# If hyperkube isn't present, we have probably never pulled the images
	# Then, pull them the first time from Github and fall back on Docker Hub
	if [[ -z $(docker images | grep "$K8S_PREFIX/hyperkube") ]]; then
		download_imgs
	fi

	# Use our normal check-and-pull process
	require-images ${REQUIRED_MASTER_IMAGES[@]}

	# Say that our master is on this board
	echo "K8S_MASTER_IP=127.0.0.1" > $KUBERNETES_CONFIG

	echo "Transferring images to system-docker, if necessary"
	# Load these master images to system-docker
	load-to-system-docker $K8S_PREFIX/etcd
	load-to-system-docker $K8S_PREFIX/flannel

	# Enable system-docker
	systemctl restart system-docker
	sleep 5

	# Enable and start our bootstrap services
	systemctl enable etcd flannel
	systemctl start etcd flannel

	# Wait for etcd and flannel
	sleep 5

	# Create a symlink to the dropin location, so docker will use flannel. Also starts docker
	dropins-enable-flannel

	# Wait for docker to come up
	sleep 5

	echo "Starting the master containers"

	# Enable these master services
	systemctl enable k8s-master
	systemctl start k8s-master

	echo "Master Kubernetes services enabled"
}

start-worker(){

	# Disable some (already running?) services
	echo "Disabling k8s if it is running"
	disable >/dev/null
	sleep 1

	# TODO: make this specifyable non-interactively
	# Check if we have a connection
	if [[ $K8S_MASTER_IP == "127.0.0.1" || $(checkformaster) != "OK" ]]; then

		# Ask for the ip
		read -p "What is the Master IP? It isn't specified or reachable at the moment. " masteripanswer

		# Required
		if [[ -z $masteripanswer ]]; then
			echo "Kubernetes Master IP is required. Exiting..."
			exit 1
		else
			echo "K8S_MASTER_IP=$masteripanswer" > $KUBERNETES_CONFIG
			K8S_MASTER_IP=$masteripanswer
		fi

		# Check again and fail if it's not working now either
		if [[ $(checkformaster) != "OK" ]]; then
			echo "The Master IP you provided isn't reachable. Exiting..."
			exit
		fi
	fi

	echo "Checks so all images are present"

	# If hyperkube isn't present, we have probably never pulled the images
	# Then, pull them the first time from Github and fall back on Docker Hub
	# Docker Pull takes 2.2x longer. A normal Github download and install may take 3 mins
	if [[ -z $(docker images | grep "$K8S_PREFIX/hyperkube") ]]; then
		download_imgs
	fi

	# TODO: checks for flannel in main docker, but it may already be in system-docker
	require-images ${REQUIRED_WORKER_IMAGES[@]}

	echo "Transferring images to system-docker, if necessary"
	# Load the images which is necessary to system-docker
	load-to-system-docker $K8S_PREFIX/flannel

	# Enable system-docker
	systemctl restart system-docker
	sleep 5

	# Enable and start our bootstrap services
	systemctl enable flannel
	systemctl start flannel

	# Wait for flannel
	sleep 5

	# Create a symlink to the dropin location, so docker will use flannel
	dropins-enable-flannel

	# Wait for docker to come up
	sleep 5

	echo "Starting the worker containers"

	# Enable these worker services
	systemctl enable k8s-worker
	systemctl start k8s-worker

	# Enable proxy mode for the worker, included in future release
	# kubectl -s http://$K8S_MASTER_IP:8080 annotate node $(hostname -i | awk '{print $1}') net.beta.kubernetes.io/proxy-mode=iptables

	echo "Worker Kubernetes services enabled"
}

start-addon(){
	# TODO: this check doesn't work
	if [[ is-active ]]; then

		if [[ -d $ADDONS_DIR/$1 ]]; then

			# The addon images are required
			require-images ${REQUIRED_ADDON_IMAGES[@]}

			# The kube-system namespace is required
			NAMESPACE=`eval "kubectl get namespaces | grep kube-system | cat"`

			# Create kube-system if necessary
			if [[ ! "$NAMESPACE" ]]; then
				kubectl create -f $ADDONS_DIR/kube-system.yaml
			fi

			# Invoke an optional addon function, if there is one
			for FILE in $ADDONS_DIR/$1/*.yaml; do
				kubectl create -f $FILE
			done

			echo "Started addon: $1"
		else
			echo "This addon doesn't exist: $1"
		fi

	else
		echo "Kubernetes is not running!"
	fi
}

stop-addon(){
	if [[ is-active ]]; then

		if [[ -d $ADDONS_DIR/$1 ]]; then
			# Stop all services
			for FILE in $ADDONS_DIR/$1/*.yaml; do
				kubectl delete -f $FILE
			done

			echo "Stopped addon: $1"
		else
			echo "This addon doesn't exist: $1"
		fi
	else
		echo "Kubernetes is not running!"
	fi
}

disable(){
	systemctl daemon-reload

	systemctl stop flannel etcd k8s-master k8s-worker
	systemctl disable flannel etcd k8s-master k8s-worker
	
	dropins-enable-overlay
}



remove-etcd-datadir(){
	read -p "Do you want to delete all Kubernetes data about this cluster? m(ove) is default, which moves the directories to {,old}. y deletes them and n exits [M/n/y] " removeanswer
	case $removeanswer in
		[nN]*)
			echo "Exiting...";;
		[yY]*)
			umount $(mount | grep /var/lib/kubelet | awk '{print $3}')
			rm -rf /var/lib/kubernetes
			rm -rf /var/lib/kubelet
			echo "Deleted all Kubernetes data";;
		*)
			umount $(mount | grep /var/lib/kubelet | awk '{print $3}')
			rm -rf /var/lib/kubeletold /var/lib/kubernetesold
			mv /var/lib/kubernetes{,old}
			mv /var/lib/kubelet{,old}
			echo "Moved all directories to {,old}";;
	esac
}

version(){
	echo "Architecture: $(uname -m)" 
	echo "Kernel: $(uname) $(uname -r | grep -o "[0-9.]*" | grep "[.]")"
	echo "CPU: $(lscpu | grep 'Core(s)' | grep -o "[0-9]*") cores x $(lscpu | grep "CPU max" | grep -o "[0-9]*" | head -1) MHz"

	echo
	echo "Used RAM Memory: $(free -m | grep Mem | awk '{print $3}') MiB"
	echo "RAM Memory: $(free -m | grep Mem | awk '{print $2}') MiB"
	echo
	echo "Used disk space: $(df -h | grep /dev/root | awk '{print $3}')B ($(df | grep /dev/root | awk '{print $3}') KB)"
	echo "Free disk space: $(df -h | grep /dev/root | awk '{print $4}')B ($(df | grep /dev/root | awk '{print $4}') KB)"
	echo

	if [[ -f $KUBERNETES_DIR/SDCard_metadata.conf ]]; then
		source $KUBERNETES_DIR/SDCard_metadata.conf
		D=$SDCARD_BUILD_DATE
		echo "SD Card was built: $(echo $D | cut -c1-2)-$(echo $D | cut -c3-4)-20$(echo $D | cut -c5-6) $(echo $D | cut -c8-9):$(echo $D | cut -c10-11)"
		echo
		echo "kubernetes-on-arm: "
		echo "Latest commit: $K8S_ON_ARM_COMMIT"
		echo "Version: $K8S_ON_ARM_VERSION"
		echo
	fi

	echo "systemd version: $(systemctl --version | head -1 | cut -c9-)"
	# Is docker running?
    docker ps 2> /dev/null 1> /dev/null
    if [ "$?" == "0" ]; then

    	echo "docker version: $(docker version | grep "Server version" | awk '{print $3}')"

    	# if kubectl exists, output k8s server version. If there is no server, output client Version
    	if [[ -f $(which kubectl 2>&1) ]]; then
    		SERVER_K8S=$(kubectl version 2>&1 | grep Server | grep -o "v[0-9.]*" | grep "[0-9]")

    		if [[ ! -z $SERVER_K8S ]]; then
    			echo "kubernetes version: $SERVER_K8S"
    		else
    			echo "kubectl version: $(kubectl version -c 2>&1 | grep Client | grep -o "v[0-9.]*" | grep "[0-9]")"
    		fi
    	fi
    fi
}

# If nothing is specified, return usage
if [[ $# == 0 ]]; then
        usage
        exit
fi

# Commands available
case $1 in
        'install')
                install;;
        'upgrade')
				upgrade;;


        'build')
				shift
				build $@;;
        'build-images')
                build ${REQUIRED_MASTER_IMAGES[@]};;
        'build-addons')
				build ${REQUIRED_ADDON_IMAGES[@]};;


        'enable-master')
                start-master;;
        'enable-worker')
                start-worker;;
        'enable-addon')
				start-addon $2;;


		'disable-node')
				disable;;
		'disable')
				disable;;
		'disable-addon')
				stop-addon $2;;


       	'delete-data')
				remove-etcd-datadir;;
        'info')
				version;;
		'help')
				usage;;
		*) 
				usage;;
esac