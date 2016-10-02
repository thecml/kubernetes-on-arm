
source os/lib/sdcard.sh

RPI_IMG_NAME="2016-09-23-raspbian-jessie-lite"
PINE64_IMG_NAME="Armbian_5.20_Pine64_Debian_jessie_4.7.0"
BPIPRO_IMG_NAME="Armbian_5.20_Bananapipro_Debian_jessie_4.7.3"

RPI_JESSIE_URL="https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2016-09-28/${RPI_IMG_NAME}.zip"
PINE64_JESSIE_URL="http://mirror.igorpecovnik.com/${PINE64_IMG_NAME}.7z"
BPIPRO_JESSIE_URL="http://mirror.igorpecovnik.com/${BPIPRO_IMG_NAME}.7z"

# Invoked by sdcard/write
mountpartitions(){
    # Partition the sd card
    # There's nothing to do here, because all this is made with dd
    echo "No extra partition work has to be done. Continuing..."
}

# Invoked by sdcard/write
initos(){
    case $MACHINENAME in
        rpi|rpi-2|rpi-3)
            generaldownload ${RPI_JESSIE_URL};;
        pine64)
            generaldownload ${PINE64_JESSIE_URL};;
        bananapro)
            generaldownload ${BPIPRO_JESSIE_URL};;
        *)
            exit;;
    esac
}

# Invoked by sdcard/write
cleanup(){
    case $MACHINENAME in
        rpi|rpi-2|rpi-3|bananapro|pine64)
            umount_root;;
        *)
            exit;;
    esac
}
