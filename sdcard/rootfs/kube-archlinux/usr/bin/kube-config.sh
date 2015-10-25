#!/bin/bash

# Catch errors
trap 'exit' ERR

PKGS_TO_INSTALL="docker git"
KUBERNETES_DIR=/etc/kubernetes
ADDONS_DIR=$KUBERNETES_DIR/addons
KUBERNETES_CONFIG=$KUBERNETES_DIR/k8s.conf
PROJECT_SOURCE=$KUBERNETES_DIR/source
K8S_PREFIX="kubernetesonarm"

# The images that are required
REQUIRED_MASTER_IMAGES=("$K8S_PREFIX/flannel $K8S_PREFIX/etcd $K8S_PREFIX/hyperkube $K8S_PREFIX/pause")
REQUIRED_WORKER_IMAGES=("$K8S_PREFIX/flannel $K8S_PREFIX/hyperkube $K8S_PREFIX/pause")
REQUIRED_ADDON_IMAGES=("$K8S_PREFIX/skydns $K8S_PREFIX/kube2sky $K8S_PREFIX/exechealthz $K8S_PREFIX/registry")

DEFAULT_TIMEZONE="Europe/Helsinki"
DEFAULT_HOSTNAME="kubepi"

LATEST_DOWNLOAD_RELEASE="v0.5.5"

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

	kube-config build-images - Build the Kubernetes images locally
	kube-config build-addons - Build the Kubernetes addon images locally
	kube-config build [image] - Build an image, which is included in the kubernetes-on-arm repository
		- Options with the luxas prefix:
			- luxas/alpine: My alpine base image
			- luxas/bench: Benchmark your ARM board compared to a Raspberry Pi 1. Based on Roy Longbottoms Benchmarks
			- luxas/go: My Golang image
			- luxas/nginx: Simple nginx image based on alpine. Used mostly for testing.
			- luxas/nodejs: node.js image based on alpine.
			- luxas/raspbian: A Raspbian base image. Based on resin/rpi-raspbian.

	kube-config enable-master - Enable the master services and then kubernetes is ready to use
		- FYI, etcd data will be stored in the /var/lib/etcd directory. Backup that directory if you have important data.
	kube-config enable-worker - Enable the worker services and then kubernetes has a new node
	kube-config enable-addon [addon] - Enable an addon
		- Currently defined addons
				- dns: Makes all services accessible via DNS
				- registry: Makes a central docker registry
				- kube-ui: Sets up an UI for Kubernetes. Experimental. Doesn't show anything useful just now, waiting for upstream.

	kube-config disable-node - Disable Kubernetes on this node, reverting the enable actions, useful if something went wrong
	kube-config disable - Synonym to disable-machine
	kube-config disable-addon [addon] - Disable an addon, not the whole cluster
	
	kube-config delete-data - Clean the /var/lib/etcd directory, where all master data is stored

	kube-config info - Outputs some version information and info about your board and Kubernetes
	kube-config help - Display this help
EOF
}


install(){


	echo "Updating the system..."
	pacman -Syu --noconfirm

	echo "Now were going to install some packages"
	pacman -S $PKGS_TO_INSTALL --noconfirm

	# Create a symlink to the dropin location, so docker will use overlay
	dropins-enable-overlay

	# Enable the system-docker service and restart both
	systemctl enable system-docker docker
	systemctl restart system-docker docker

	echo "Downloading prebuilt binaries. It is possible to build them manually later."
	# First, symlink the latest binaries directory to a better place
	ln -s $PROJECT_SOURCE/images/kubernetesonarm/_bin/latest $KUBERNETES_DIR/binaries

	# Download latest binaries, now we have them in $PATH
	curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/$LATEST_DOWNLOAD_RELEASE/binaries.tar.gz | tar -xz -C $KUBERNETES_DIR/binaries


	echo "Set the timezone"
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
		read -p "Do you want to create an 1GB swapfile (useful for compiling)? n is default [Y/n] " swapanswer
		
		case $swapanswer in
			[yY]*)
				swap;;
		esac
	elif [[ $SWAP == 1 ]]; then
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

	# Download prebuilt docker images
	if [[ -z $DOWNLOAD_IMAGES ]]; then
		read -p "Do you want to download Kubernetes for ARM docker images? So you won't have to build them yourself. Y is default. [Y/n] " downloadanswer

		case $downloadanswer in
			[nN]*)
				echo "OK. Continuing...";;
			*)
				download_imgs;;
		esac

	elif [[ $DOWNLOAD_IMAGES == 1 ]]; then
		download_imgs
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
	elif [[ $REBOOT == 1 ]]; then
		reboot
	fi
}

swap(){
	echo "Make an 1GB swapfile, NOTE: it takes up precious SD Card space"

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
	rm -r /tmp/dlk8s
	mkdir -p /tmp/dlk8s

	# Get the uploaded archive
	curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/$LATEST_DOWNLOAD_RELEASE/images.tar.gz | tar -xz -C /tmp/dlk8s

	# And load it to docker
	docker load -i /tmp/dlk8s/images.tar

	rm -r /tmp/dlk8s
}

### --------------------------------- HELPERS -----------------------------------

# A forwarder to the build script in the repo
build(){
	$PROJECT_SOURCE/images/build.sh "$@"
}

# Remove all docker dropins. They are symlinks, so it doesn't matter
dropins-clean(){
	mkdir -p /usr/lib/systemd/system/docker.service.d/
	rm -f /usr/lib/systemd/system/docker.service.d/*.conf

	systemctl daemon-reload
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

			echo "Can't spin up Kubernetes without these images: $@"
			pull-images "$@"
			break
		fi
	done
}

pull-images(){

	echo "Tries to pull them instead."

	# For each 
	for IMAGE in "$@"; do

		if [[ -z $(docker images | grep "$IMAGE") ]]; then

			# Try to pull the image
			docker pull $IMAGE

			# Double-check if it's here
			if [[ -z $(docker images | grep "$IMAGE") ]]; then

				echo "Pull failed. Try to pull these images yourself: $@"
				exit
			fi
		fi
	done

	# If kubectl doesn't exist, download from github
	#if [[ ! -f /usr/bin/kubectl ]]; then
		#echo "Downloading kubectl..."
		#curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/v0.5.5/kubectl > /usr/bin/kubectl
		#chmod +x /usr/bin/kubectl
	#fi
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
	local minionstate=$(systemctl is-active k8s-worker)
	local masterstate=$(systemctl is-active k8s-master)
	if [[ minionstate == "active" ]]; then
		echo "minion";
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

	# Enable these minion services
	systemctl enable k8s-worker
	systemctl start k8s-worker

	echo "Worker Kubernetes services enabled"
}

start-addon(){
	if [[ is-active ]]; then

		# The addon images are required
		# Todo, make faster
		require-images ${REQUIRED_ADDON_IMAGES[@]}

		# Invoke an optional addon function
		case $1 in
			'dns') addon-dns;;

			# For each file in the addon dir, kubectl create
			*) 	for FILE in $ADDONS_DIR/$1/*.yaml; do
					kubectl create -f $FILE
				done;;
		esac
			

		echo "Started addon: $1"
	else
		echo "Kubernetes is not running!"
	fi
}

stop-addon(){
	if [[ is-active ]]; then

		# Stop all services
		for FILE in $ADDONS_DIR/$1/*.yaml; do
			kubectl delete -f $FILE
		done

		echo "Stopped addon: $1"
	else
		echo "Kubernetes is not running!"
	fi
}

# Start the dns customized
addon-dns(){
	# Replace the KUBEMASTER placeholder with the master ip temporary, until service accounts is in place
	if [[ $K8S_MASTER_IP == "127.0.0.1" ]]; then
		K8S_MASTER_IP=$(hostname -i | awk '{print $1}')
	fi

	sed -e "s@KUBEMASTER@http://$K8S_MASTER_IP:8080@" $ADDONS_DIR/dns/dns-rc.yaml | kubectl create -f -
	kubectl create -f $ADDONS_DIR/dns/dns-svc.yaml
}

disable(){
	systemctl daemon-reload

	systemctl stop flannel etcd k8s-master k8s-worker
	systemctl disable flannel etcd k8s-master k8s-worker
	
	dropins-enable-overlay
}



remove-etcd-datadir(){
	read -p "Do you want to delete all Kubernetes data about this cluster? n is default [Y/n] " removeanswer
	case $removeanswer in
		[yY]*)
			rm -r /var/lib/etcd
			echo "Deleted all Kubernetes data";;
	esac
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

# If nothing is specified, return usage
if [[ $# == 0 ]]; then
        usage
        exit
fi

# Commands available
case $1 in
        'install')
                install;;


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
esac