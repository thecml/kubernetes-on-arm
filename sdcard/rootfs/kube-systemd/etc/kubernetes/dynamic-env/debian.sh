# Args: "$@" == the minimum packages to install, e.g. docker, git
os_install(){

	# Update the system and use pacman to install all the packages
	# The two commands may be combined, but I leave it as is for now.
	os_upgrade
	
	# Here docker have to be installed
	# TODO
}


os_upgrade(){
	apt-get update -y && apt-get upgrade -y
}