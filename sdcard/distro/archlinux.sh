dlandextract(){
	# Download 
	curl -sSL -k http://archlinuxarm.org/os/ArchLinuxARM-${MACHINENAME}-latest.tar.gz | tar -zxf -C $ROOT
}

populateboot(){
	# Move /boot to separate partition
	mv $ROOT/boot/* $BOOT
}