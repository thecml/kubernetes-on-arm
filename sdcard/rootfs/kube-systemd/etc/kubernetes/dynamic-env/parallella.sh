# This command is run by kube-config when doing "kube-config install"
post_install(){

	# Parallella patch, specific to this rootfs. Disable overlay, because linux 3.14 doesn't have overlay support
	sed -e "s@-s overlay@@" -i $K8S_DIR/dropins/docker-flannel.conf
	sed -e "s@-s overlay@@" -i $K8S_DIR/dropins/docker-overlay.conf
}