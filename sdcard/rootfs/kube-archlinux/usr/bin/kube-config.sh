#!/bin/bash

# Catch errors
trap 'exit' ERR


usage(){
	cat <<EOF
Welcome to kube-config!

With this utility, you can setup kubernetes on ARM!

Usage: 
	kube-config install - Installs docker and makes your board ready for kubernetes

	kube-config build-master - Build the master images locally 
	kube-config build-minion - Build the minion images locally 

	kube-config enable-master - Enable the master services and then kubernetes is ready to use
	kube-config enable-minion - Enable the minion services and then kubernetes has a new node

	kube-config version - Outputs some version information and info about your board

EOF
}




install(){

	# Could these two pacman commands be combined?
	echo "Updating the system..."
	#time pacman -Syu --noconfirm

	echo "Now were going to install some packages"
	pacman -S docker git make nmap --noconfirm
	
	# Remove docker dropin files
	rm -f /usr/lib/systemd/system/docker.service.d/docker*.conf

	# Ensure the path exists
	mkdir -p /usr/lib/systemd/system/docker.service.d

	# Create a symlink to the dropin location, so docker will use overlay
	ln -s /etc/kubernetes/dynamic-dropins/docker-overlay.conf /usr/lib/systemd/system/docker.service.d/docker-overlay.conf

	# Notify systemd
	systemctl daemon-reload

	## REMOVE THIS THEN ##

	mkdir -p /lib/luxas/luxcloud.git && cd /lib/luxas/luxcloud.git

	# Make version control
	git init --bare

	cat > hooks/post-receive <<EOF
	#!/bin/bash
	git --work-tree=/etc/kubernetes/source --git-dir=/lib/luxas/luxcloud.git checkout -f
	find /etc/kubernetes/source -name "*.sh" -exec chmod +x {} \;
	chmod +x /etc/kubernetes/source/utils/strip-image/*
EOF

	chmod a+x hooks/post-receive
	cd -


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

	read -p "Do you want to reboot now? A reboot is required for Docker to function. [Y/n] " rebootanswer

	case $rebootanswer in
		[yY]*)
			reboot;;
	esac
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


start-master(){
	### REQUIRED IMAGES FOR THIS TO WORK ###

	# List them here
	REQUIRED_IMAGES=("k8s/flannel k8s/etcd k8s/hyperkube k8s/pause")

	# Check that everyone exists or fail fast
	for IMAGE in ${REQUIRED_IMAGES[@]}; do
		if [[ -z $(docker images | grep "$IMAGE") ]]; then
			echo "Error: Can't spin up the Kubernetes master service without these images: ${REQUIRED_IMAGES[@]}"
			exit 1
		fi
	done

	# Say that our master is on this board
	cat > /etc/kubernetes/k8s.conf <<EOF
K8S_MASTER_IP=127.0.0.1
EOF


	# Load the images which is necessary to system-docker 
	if [[ -z $(docker images | grep "k8s/etcd") ]]; then
		docker save k8s/etcd | docker -H unix:///var/run/system-docker.sock load
	fi
	if [[ -z $(docker images | grep "k8s/flannel") ]]; then
		docker save k8s/flannel | docker -H unix:///var/run/system-docker.sock load
	fi

	# Enable and start our bootstrap services
	systemctl enable flannel etcd
	systemctl start etcd flannel

	# Remove docker dropin files
	rm /usr/lib/systemd/system/docker.service.d/docker*.conf

	# Create a symlink to the dropin location, so docker will use flannel
	ln -s /etc/kubernetes/dynamic-dropins/docker-flannel.conf /usr/lib/systemd/system/docker.service.d/docker-flannel.conf

	# Systemd would like to be notified about our new files
	systemctl daemon-reload

	# Bring docker up again
	systemctl restart docker 

	# Enable these master services
	systemctl enable master-k8s
	systemctl start master-k8s
}

start-minion(){

	# Check if we have a connection
	if [[ $(checkformaster) != "OK" ]]; then

		# Ask for the ip
		read -p "What is the master ip? It isn't specified or reachable at the moment." masteripanswer

		# Required
		if [[ -z $masteripanswer ]]; then
			echo "Kubernetes master ip is required. Exiting..."
			exit 1
		else
			cat > /etc/kubernetes/k8s.conf <<EOF
K8S_MASTER_IP=$masteripanswer
EOF
		fi

		# Check again and fail if it's not working now either
		if [[ $(checkformaster) != "OK" ]]; then
			echo "The master ip you provided isn't reachable. Exiting..."
		fi
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


	# Load the images which is necessary to system-docker
	if [[ -z $(docker images | grep "k8s/flannel") ]]; then
		docker save k8s/flannel | docker -H unix:///var/run/system-docker.sock load
	fi

	# Enable and start our bootstrap services
	systemctl enable flannel
	systemctl start flannel

	# Remove docker dropin files
	rm -f /usr/lib/systemd/system/docker.service.d/docker*.conf

	# Ensure the path exists
	mkdir -p /usr/lib/systemd/system/docker.service.d

	# Create a symlink to the dropin location, so docker will use flannel
	ln -s /etc/kubernetes/dynamic-dropins/docker-flannel.conf /usr/lib/systemd/system/docker.service.d/docker-flannel.conf

	# Systemd would like to be notified about our new files
	systemctl daemon-reload

	# Bring docker up again
	systemctl restart docker 

	# Enable these master services
	systemctl enable master-k8s
	systemctl start master-k8s
}

checkformaster(){

	# Is the config file there? Then source it
	if [[ -f /etc/kubernetes/k8s.conf ]]; then
		source /etc/kubernetes/k8s.conf

		# If ping doesn't return unknown, its OK
		if [[ -z $(ping -c1 $K8S_MASTER_IP | grep unknown) ]]; then
			echo "OK"
		fi
	fi
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
      	if [[ ! -z $(docker images | grep k8s/hyperkube) ]]; then
      		docker run --rm k8s/hyperkube hyperkube --version
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
        'build-master')
                build "k8s/hyperkube k8s/pause k8s/etcd k8s/flannel";;
        'build-minion')
                build "k8s/hyperkube k8s/pause k8s/flannel";;
        'enable-master')
                start-master;;
        'enable-minion')
                start-minion;;
        'version')
                version;;
esac