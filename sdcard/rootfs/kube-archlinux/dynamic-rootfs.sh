
K8S_DIR="$ROOT/etc/kubernetes"
SDCARD_METADATA_FILE=$K8S_DIR/SDCard_metadata.conf

rootfs(){

	# Allow ssh connections by root to this machine
	if [[ -f $ROOT/etc/ssh/sshd_config ]]; then
		echo "PermitRootLogin yes" >> $ROOT/etc/ssh/sshd_config
	fi

	# Shortcut for running tests
	ln -s ../../etc/kubernetes/source/scripts/run-test.sh $ROOT/usr/bin/run-test

	# Copy current source
	mkdir $K8S_DIR/source
	cp -r $PROJROOT $K8S_DIR/source

	# Remove the .sh
	mv $ROOT/usr/bin/kube-config{.sh,}

	# Make the docker dropin directory
	mkdir -p $ROOT/usr/lib/systemd/system/docker.service.d
	ln -s ../../../../../etc/kubernetes/dropins/docker-overlay.conf $ROOT/usr/lib/systemd/system/docker.service.d/docker-overlay.conf

 	# Symlink latest built binaries to an easier path
	mkdir -p $K8S_DIR/source/images/kubernetesonarm/_bin/latest
	ln -s ./source/kubernetesonarm/_bin/latest $K8S_DIR/binaries

	# Symlink the addons to an easier path
	ln -s ./source/addons $K8S_DIR

	# Inform the newly created SD Cards' scripts about which files to use.
	cat > $K8S_DIR/dynamic-env/env.conf <<EOF
OS=$OSNAME
MACHINE=$MACHINENAME
EOF

	# Remember the time we built this SD Card
	echo -e "SDCARD_BUILD_DATE=\"$(date +%d%m%y_%H%M)\"" >> $SDCARD_METADATA_FILE

	COMMIT=$(git log --oneline 2>&1 | head -1 | awk '{print $1}')
	if [[ $COMMIT != "bash:"* && $COMMIT != "fatal:"* ]]; then
		echo "K8S_ON_ARM_COMMIT=$COMMIT" >> $SDCARD_METADATA_FILE
	fi

	source ../version
	echo "K8S_ON_ARM_VERSION=$VERSION" >> $SDCARD_METADATA_FILE

	# Parallella patch, specific to this rootfs. Disable overlay, because linux 3.14 doesn't have overlay support
	if [[ $MACHINENAME == "parallella" ]]; then
		
		sed -e "s@-s overlay@@" -i $K8S_DIR/dropins/docker-flannel.conf
		sed -e "s@-s overlay@@" -i $K8S_DIR/dropins/docker-overlay.conf
	fi
}
