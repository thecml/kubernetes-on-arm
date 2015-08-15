domiddleware(){

	cd "$( dirname "${BASH_SOURCE[0]}" )"

	# First, do the common things
	source luxcloud-common.sh
	docommon

	# Copy over the k8s master script
	cp $CURRENT_INSTALLATION_DIR/k8s-master.sh $LUXDIR

	# And rename it to k8s for calling by luxcloud
	mv $LUXDIR/k8s-master.sh $LUXDIR/k8s.sh

	# Specify role
	echo -e "ROLE=\"MASTER\" \n" >> $LUXDIR/config.sh
}