
os_install(){

	# Update the system and use pacman to install all the packages
	pacman -Syu --noconfirm

	if [[ -z $STATICALLY_DOCKER ]]; then

		if [[ $MACHINE == "rpi" ]]; then
			pacman -S docker git --noconfirm --needed
		else
			# for armv7
			# Install this manually, docker v1.7.1
			pacman -S bridge-utils iproute2 device-mapper sqlite git --noconfirm --needed
			curl -sSL https://s3.amazonaws.com/docker-armv7/docker-1:1.7.1-2-armv7h.pkg.tar.xz > /var/cache/pacman/pkg/docker-1:1.7.1-2-armv7h.pkg.tar.xz
			pacman -U  /var/cache/pacman/pkg/docker-1:1.7.1-2-armv7h.pkg.tar.xz --noconfirm
		fi
	else
		# Install git
		pacman -S git --noconfirm --needed

		# Download docker daemon
		curl -sSL $STATIC_DOCKER_DOWNLOAD > /usr/bin/docker
		chmod +x /usr/bin/docker

		# Add the docker group, so the daemon starts
		groupadd docker

		# Enable the service files
		mv /usr/lib/systemd/system/docker.service{.backup,}
		mv /usr/lib/systemd/system/docker.socket{.backup,}

		systemctl daemon-reload
	fi
	# Add more commands here, archlinux specific
}


os_upgrade(){

	if [[ $MACHINE == "rpi" ]]; then
		pacman -Syu --noconfirm
	else
		echo "Won't upgrade your system. It would result in a corrupt docker download from pacman."
		echo "If you want to do it anyway, run pacman -Syu"
	fi
}

os_post_install(){
	# When on Arch Linux, we've just installed docker, so reboot before use.
	systemctl stop system-docker docker
}