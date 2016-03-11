#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/..
source scripts/common.sh


DISC=$1
TARGET_DIR=$(parse-path-or-disc $2)/kubernetesonarm_sdcard_images_$(date +%d%m%y_%H%M)
SIZE=${3:-1000}
VERSION=${VERSION:-"v0.6.0"}
BOARD=${BOARD:-"rpi-2"}
WRITE=${WRITE:-0}

if [[ $# < 2 ]]; then
    cat <<EOF
Usage:
scripts/mkimg.sh [disc] [target dir or disc] [size in MB]

scripts/mkimg.sh /dev/sda /etc/kubernetes/sdcard_images 900

# Package rpi
BOARD=rpi WRITE=1 scripts/mkimg.sh /dev/sda /root 900

# Package rpi and write directly to /dev/sdb (which could be an usb stick)
BOARD=rpi WRITE=1 scripts/mkimg.sh /dev/sda /dev/sdb 900 [/dev/sdb1 automatically chosen, it possible to specify partition directly too]
EOF
else
    
    if [[ -z $(fdisk -l | grep $DISC) ]]; then
        echo "Specify a disc that exists."
        exit
    fi

    if [[ $WRITE == 1 ]]; then

        echo "Writing the SD Card"
        # Partition the sdcard a little bit smaller than our .img file
        export SDCARDSIZE=$((SIZE-12))
        time QUIET=1 sdcard/write.sh $DISC $BOARD archlinux kube-systemd
    fi

    IMGFILE="$TARGET_DIR/kubernetes-on-arm-$VERSION-$BOARD.img"

    mkdir -p $TARGET_DIR

    echo "Reading the disc to a file"
    time dd if=$1 of=$IMGFILE bs=4M count=$((SIZE/4))


    if [[ -f $TARGET_ZIP ]]; then
        read -p "The target file will be removed. Continue? [Y/n] " continueanswer

        case $continueanswer in
            [nN]*)
                exit;;
        esac
    fi

    echo "Zipping the target for smaller space"
    time zip -j $TARGET_DIR/sdcard-$BOARD.zip $IMGFILE

    cleanup-path-or-disc
fi