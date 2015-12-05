# Args: "$@" == the minimum packages to install, e.g. docker, git
os_install(){

	# Update the system and use pacman to install all the packages
	# The two commands may be combined, but I leave it as is for now.
	os_upgrade
	
	# Since docker and git is installed by default, we have nothing more to do here
}


os_upgrade(){
	apt-get update -y && apt-get upgrade -y
}