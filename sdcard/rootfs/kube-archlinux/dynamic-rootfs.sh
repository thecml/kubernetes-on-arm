rootfs(){
	# Allow ssh connections by root to this machine
	echo "PermitRootLogin yes" >> $ROOT/etc/ssh/sshd_config

	# Copy current source
	mkdir $ROOT/etc/kubernetes/source
	cp -r $PROJROOT $ROOT/etc/kubernetes/source

	# Remove the .sh
	mv $ROOT/usr/bin/kube-config.sh $ROOT/usr/bin/kube-config

	# Make the docker dropin directory
	mkdir -p $ROOT/usr/lib/systemd/system/docker.service.d

	# Copy the addons
	mkdir -p $ROOT/etc/kubernetes/addons
	cp -r $PROJROOT/addons/k8s/* $ROOT/etc/kubernetes/addons/


	# Parallella patch. Disable overlay, because linux 3.14 doesn't have overlay support
	if [[ $MACHINENAME == "parallella" ]]; then
		
		sed -e "s@-s overlay@@" -i $ROOT/etc/kubernetes/dynamic-dropins/docker-flannel.conf
		sed -e "s@-s overlay@@" -i $ROOT/etc/kubernetes/dynamic-dropins/docker-overlay.conf
	elif [[ $MACHINENAME == "rpi" || $MACHINENAME == "rpi-2" ]]; then

		# Enable memory and swap accounting
		sed -e "s@console=tty1@console=tty1 cgroup_enable=memory swapaccount=1@" -i $BOOT/cmdline.txt
	fi
}
