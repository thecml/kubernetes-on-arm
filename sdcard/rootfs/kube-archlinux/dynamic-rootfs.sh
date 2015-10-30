
K8S_DIR="$ROOT/etc/kubernetes"
SDCARD_METADATA_FILE=$K8S_DIR/SDCard_metadata.conf

rootfs(){
	# Allow ssh connections by root to this machine
	echo "PermitRootLogin yes" >> $ROOT/etc/ssh/sshd_config

	# Copy current source
	mkdir $K8S_DIR/source
	cp -r $PROJROOT $K8S_DIR/source

	# Remove the .sh
	mv $ROOT/usr/bin/kube-config.sh $ROOT/usr/bin/kube-config

	# Make the docker dropin directory
	mkdir -p $ROOT/usr/lib/systemd/system/docker.service.d

	# Copy the addons ot the kubernetes directory
	cp -r $PROJROOT/addons $K8S_DIR

	# Remember the time we built this SD Card
	echo -e "SDCARD_BUILD_DATE=\"$(date +%d%m%y_%H%M)\"" >> $SDCARD_METADATA_FILE

	COMMIT=$(git log --oneline 2>&1 | head -1 | awk '{print $1}')
	if [[ $COMMIT != "bash:" && $COMMIT != "fatal:" ]]; then
		echo -e "\nK8S_ON_ARM_COMMIT=$COMMIT" >> $SDCARD_METADATA_FILE
	fi

	source ../version
	echo -e "\nK8S_ON_ARM_VERSION=$VERSION" >> $SDCARD_METADATA_FILE

	# These patches should be moved to board specific scripts
	# Parallella patch. Disable overlay, because linux 3.14 doesn't have overlay support
	if [[ $MACHINENAME == "parallella" ]]; then
		
		sed -e "s@-s overlay@@" -i $K8S_DIR/dropins/docker-flannel.conf
		sed -e "s@-s overlay@@" -i $K8S_DIR/dropins/docker-overlay.conf
	elif [[ $MACHINENAME == "rpi" || $MACHINENAME == "rpi-2" ]]; then

		# Enable memory and swap accounting
		sed -e "s@console=tty1@console=tty1 cgroup_enable=memory swapaccount=1@" -i $BOOT/cmdline.txt
	fi
}
