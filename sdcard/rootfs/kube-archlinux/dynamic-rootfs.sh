
rootfs(){
	# Allow ssh connections by root to this machine
	echo "PermitRootLogin yes" >> $ROOT/etc/ssh/sshd_config

	# The root path of this project
	PROJROOT="$( dirname "${BASH_SOURCE[0]}" )"/../../..

	# Copy current source
	cp -r $PROJROOT/images $ROOT/etc/kubernetes/

}

