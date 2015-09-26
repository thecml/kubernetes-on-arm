rootfs(){
	# Allow ssh connections by root to this machine
	echo "PermitRootLogin yes" >> $ROOT/etc/ssh/sshd_config

	# Copy current source
	mkdir $ROOT/etc/kubernetes/source

	cp -r $PROJROOT $ROOT/etc/kubernetes/source

	# If kubectl exists, include in rootfs
	if [[ -f $PROJROOT/k8s/_bin/latest/kubectl ]]; then
		cp $PROJROOT/k8s/_bin/latest/kubectl $ROOT/usr/bin
	fi

	# Remove the .sh
	mv $ROOT/usr/bin/kube-config.sh $ROOT/usr/bin/kube-config
}
