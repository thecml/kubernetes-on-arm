rootfs(){
	# Allow ssh connections by root to this machine
	echo "PermitRootLogin yes" >> $ROOT/etc/ssh/sshd_config

	# Copy current source
	mkdir $ROOT/etc/kubernetes/source
	cp -r $PROJROOT $ROOT/etc/kubernetes/source

	# If kubectl exists, include in rootfs
	if [[ -f $PROJROOT/kubernetesonarm/_bin/latest/kubectl ]]; then
		cp $PROJROOT/kubernetesonarm/_bin/latest/kubectl $ROOT/usr/bin
	fi

	# Remove the .sh
	mv $ROOT/usr/bin/kube-config.sh $ROOT/usr/bin/kube-config

	# Make the docker dropin directory
	mkdir -p $ROOT/usr/lib/systemd/system/docker.service.d

	# Copy the addons
	mkdir -p $ROOT/etc/kubernetes/addons
	cp -r $PROJROOT/services/k8s/dns $ROOT/etc/kubernetes/addons/
	cp -r $PROJROOT/services/k8s/registry $ROOT/etc/kubernetes/addons/
}
