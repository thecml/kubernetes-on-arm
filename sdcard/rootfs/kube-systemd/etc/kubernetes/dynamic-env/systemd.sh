# Args: "$@" == the minimum packages to install, e.g. docker, git
os_install(){

	# Update the system and use pacman to install all the packages
	# The two commands may be combined, but I leave it as is for now.
	os_upgrade
	
	# Here docker have to be installed
	# Download docker daemon
	curl -sSL $STATIC_DOCKER_DOWNLOAD > /usr/bin/docker
	chmod +x /usr/bin/docker

	# Add the docker group, so the daemon starts
	groupadd docker

	# Enable the service files
	mv /usr/lib/systemd/system/docker.service{.backup,}
	mv /usr/lib/systemd/system/docker.socket{.backup,}

	systemctl daemon-reload

	# If the raspi-config command exists, expand filesystem automatically
	if [[ -f $(which raspi-config 2>&1) ]]; then
		raspi-config --expand-rootfs
	fi

	# If brctl isn't installed, notify the user
	if [[ ! -f $(which brctl 2>&1) ]]; then

		# Install automatically if apt-get is present
		if [[ -f $(which apt-get 2>&1) ]]; then
			apt-get install bridge-utils -y
		else
			echo "WARNING: brctl is required for Kubernetes to function. Install it if you want Kubernetes to function properly."
		fi
	fi
}


os_upgrade(){
	# If apt-get is there, use it
	if [[ -f $(which apt-get 2>&1) ]]; then
		echo "Updating your system"
		apt-get update -y && apt-get upgrade -y
	else
		echo "Don't know which package manager you are using. Refresh your OS yourself."
	fi

	# If the dhclient config file exists, edit it
	if [[ -f /etc/dhcp/dhclient.conf ]]; then
		cat >> /etc/dhcp/dhclient.conf <<EOF 
prepend domain-search "default.svc.cluster.local","svc.cluster.local","cluster.local";
prepend domain-name-servers 10.0.0.10;
EOF
	fi
}