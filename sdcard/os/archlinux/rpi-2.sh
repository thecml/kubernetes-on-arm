# This command is run by kube-config when doing "kube-config install"
post_install(){

	# Enable memory and swap accounting
	sed -e "s@console=tty1@console=tty1 cgroup_enable=memory swapaccount=1@" -i /boot/cmdline.txt
}