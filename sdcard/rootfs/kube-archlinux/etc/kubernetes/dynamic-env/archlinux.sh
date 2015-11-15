# Args: "$@" == the minimum packages to install, e.g. docker, git
os_install(){

	# Update the system and use pacman to install all the packages
	# The two commands may be combined, but I leave it as is for now.
	pacman -Syu --noconfirm
	pacman -S $@ --noconfirm --needed

	# Add more commands here, archlinux specific
}


os_upgrade(){
	pacman -Syu --noconfirm
}