

RPI_HYPRIOTOS_RELEASE="hypriot-rpi-20151115-132854"
RPI_DOWNLOAD_LINK=http://downloads.hypriot.com/${RPI_HYPRIOTOS_RELEASE}.img.zip

ODROID_C1_HYPRIOTOS_VERSION="v0.2.1"
ODROID_C1_HYPRIOTOS_RELEASE="sd-card-odroid-c1-${ODROID_C1_HYPRIOTOS_VERSION}"
ODROID_C1_DOWNLOAD_LINK=https://github.com/hypriot/image-builder-odroid-c1/releases/download/${ODROID_C1_HYPRIOTOS_VERSION}/${ODROID_C1_HYPRIOTOS_RELEASE}.img.zip


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
			generaldownload $RPI_DOWNLOAD_LINK $RPI_HYPRIOTOS_RELEASE;;
		odroid-c1)
			generaldownload $ODROID_C1_DOWNLOAD_LINK $ODROID_C1_HYPRIOTOS_RELEASE;;
		*)
			exit;;
	esac
}

# Invoked by sdcard/write
cleanup(){
	case $MACHINENAME in
		rpi|rpi-2|odroid-c1)
			umount_root;;
		*)
			exit;;
	esac
}


# Takes an URL (.img.zip file) to download an the name of the downloaded file. Assumes that the extracted and the downloaded file has the same names except for the extension
generaldownload(){

	# Install unzip if not present
	require unzip unzip

	# Ensure this page is present
	mkdir -p /etc/tmp

	# We can't write this .img file to /tmp because /tmp has a limit of 462MB
	DLDIR=/etc/tmp/downloadhypriot
	DL_LINK=$1
	RELEASE=$2
	ZIPFILE=$DLDIR/${RELEASE}.img.zip

	if [[ ! -f $ZIPFILE ]]; then
		curl -sSL $DL_LINK > $ZIPFILE
	fi

	unzip $ZIPFILE -d $DLDIR

	dd if=$DLDIR/${RELEASE}.img of=$SDCARD bs=4M

	sync

	mount $PARTITION2 $ROOT
	# Will take ~9 mins on a Pi
}

umount_root(){
	umount $ROOT
}