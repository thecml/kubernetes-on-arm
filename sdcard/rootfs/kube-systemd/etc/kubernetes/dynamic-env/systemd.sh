# Args: "$@" == the minimum packages to install, e.g. docker, git
os_install(){

	# Update the system and use pacman to install all the packages
	# The two commands may be combined, but I leave it as is for now.
	os_upgrade
	
	# Here docker have to be installed
	# Download docker daemon
	curl -sSL $STATIC_DOCKER_DOWNLOAD > /usr/bin/docker

	# Enable the service files
	mv /usr/lib/systemd/system/docker.service{.backup,}
	mv /usr/lib/systemd/system/docker.socket{.backup,}

	systemctl daemon-reload
}


os_upgrade(){
	# If apt-get is there, use it
	if [[ -f $(which apt-get 2>&1) ]]; then
		apt-get update -y && apt-get upgrade -y
	else
		echo "Don't know which package manager you are using. Refresh your OS yourself."
	fi
}