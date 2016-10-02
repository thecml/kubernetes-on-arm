
source os/lib/sdcard.sh

HYPRIOTOS_VERSION="v1.0.1"
HYPRIOTOS_URL="https://github.com/hypriot/image-builder-rpi/releases/download/${HYPRIOTOS_VERSION}/hypriotos-rpi-${HYPRIOTOS_VERSION}.img.zip"

# First invoked by sdcard/write
mountpartitions(){
    # Partition the sd card
    # There's nothing to do here, because all this is made with dd
    echo "No extra partition work has to be done. Continuing..."
}

# Invoked by sdcard/write
initos(){
    case ${MACHINENAME} in
        rpi|rpi-2|rpi-3)
            generaldownload ${HYPRIOTOS_URL};;
        *)
            exit;;
    esac
}

# Invoked by sdcard/write
cleanup(){
    case ${MACHINENAME} in
        rpi|rpi-2|rpi-3)
            umount_root;;
        *)
            exit;;
    esac
}
