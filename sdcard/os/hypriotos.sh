

# First invoked by sdcard/write
mountpartitions(){
	# Partition the sd card
	# There's nothing to do here, because all this is made with dd
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
			umount_boot_and_root;;
		*)
			exit;;
	esac
}


generaldownload(){

	# We can't write this .img file to /tmp because /tmp has a limit of 462MB for the files there
	DLDIR=$(mktemp -d /etc/tmp/downloadhypriot.XXXXXXXX)
	curl -sSL http://downloads.hypriot.com/hypriot-rpi-20151115-132854.img.zip > $DLDIR/hypriotos.img.zip

	unzip /etc/tmp/hypriotos.img.zip -d $DLDIR

	dd if=$(ls $DLDIR/*.img) of=

}