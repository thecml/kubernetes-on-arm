

# First invoked by sdcard/write
mountpartitions(){
	# Partition the sd card
	# There's nothing to do here, because all this is made with dd
	echo "No extra partition work has to be done. Continuing..."
}

# Invoked by sdcard/write
initos(){
	case $MACHINENAME in
		rpi|rpi-2)
			generaldownload;;
		*)
			exit;;
	esac
}

# Invoked by sdcard/write
cleanup(){
	case $MACHINENAME in
		rpi|rpi-2)
			umount_root;;
		*)
			exit;;
	esac
}


generaldownload(){

	mkdir -p /etc/tmp
	# We can't write this .img file to /tmp because /tmp has a limit of 462MB for the files there
	DLDIR=$(mktemp -d /etc/tmp/downloadhypriot.XXXXXXXX)
	curl -sSL http://downloads.hypriot.com/hypriot-rpi-20151115-132854.img.zip > $DLDIR/hypriotos.img.zip

	unzip $DLDIR/hypriotos.img.zip -d $DLDIR

	dd if=$(ls $DLDIR/*.img) of=$SDCARD bs=4M

	sync

	mount $PARTITION2 $ROOT
	# Will take ~9 mins on a Pi
}

umount_root(){
	umount $ROOT
}