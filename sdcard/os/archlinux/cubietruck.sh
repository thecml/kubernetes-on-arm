# This command is run by kube-config when doing "kube-config install"
post_install(){

	# Customized commands just for cubietruck
	pacman -S uboot-cubietruck
}