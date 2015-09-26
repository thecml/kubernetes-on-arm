rootfs(){
	# Allow ssh connections by root to this machine
	echo "PermitRootLogin yes" >> $ROOT/etc/ssh/sshd_config

	# Copy current source
	cp -r $PROJROOT/images $ROOT/etc/kubernetes/

	# If kubectl exists, include in rootfs
	if [[ -f $PROJROOT/k8s/_bin/latest/kubectl ]]; then
		cp $PROJROOT/k8s/_bin/latest/kubectl $ROOT/usr/bin
	fi

	# Remove the .sh
	mv $ROOT/usr/bin/kube-config.sh $ROOT/usr/bin/kube-config
}
