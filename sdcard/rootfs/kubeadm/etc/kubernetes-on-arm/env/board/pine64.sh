# This command is run by kube-config when doing "kube-config install"
board_install(){
	echo "STORAGE_DRIVER=aufs" > /etc/kubernetes-on-arm/storagedriver.conf
}
