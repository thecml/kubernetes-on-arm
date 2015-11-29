# Args: "$@" == the minimum packages to install, e.g. docker, git
os_install(){

	# Update the system and use pacman to install all the packages
	# The two commands may be combined, but I leave it as is for now.
	os_upgrade
	# pacman -S $@ --noconfirm --needed

	if [[ $MACHINE == "rpi" ]]; then
		pacman -S $@ --noconfirm --needed
	else
		# for armv7
		# Install this manually, docker v1.7.1
		pacman -S bridge-utils iproute2 device-mapper sqlite git --noconfirm --needed
		curl -sSL https://s3.amazonaws.com/docker-armv7/docker-1:1.7.1-2-armv7h.pkg.tar.xz > /var/cache/pacman/pkg/docker-1:1.7.1-2-armv7h.pkg.tar.xz
		pacman -U  /var/cache/pacman/pkg/docker-1:1.7.1-2-armv7h.pkg.tar.xz --noconfirm
	fi
	# Add more commands here, archlinux specific
}


os_upgrade(){
	pacman -Syu --noconfirm
}