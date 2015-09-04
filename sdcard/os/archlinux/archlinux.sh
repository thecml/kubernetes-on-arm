initos(){
	# Download 
	curl -sSL -k http://archlinuxarm.org/os/ArchLinuxARM-${MACHINENAME}-latest.tar.gz | tar -xz -C $ROOT

	sync

	# Move /boot to separate partition
	mv $ROOT/boot/* $BOOT
}