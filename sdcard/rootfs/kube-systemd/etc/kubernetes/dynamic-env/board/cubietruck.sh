# This command is run by kube-config when doing "kube-config install"
board_post_install(){

	# Install the cubietruck uboot package
	pacman -S uboot-cubietruck --noconfirm
}