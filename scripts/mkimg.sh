#!/bin/bash

DISC=$1
TARGET_FILE=$2

if [[ $# != 2 ]]; then
	cat <<EOF
Usage:
scripts/mkimg.sh [disc] [target file]

scripts/mkimg.sh /dev/sda /root/sdcard.img.tar.gz
EOF

if [[ -z $(fdisk -l | grep $DISC) ]]; then
	echo "Specify a disc that exists."
	exit
fi

TMPFILE=$(mktemp /tmp/mkk8simg.XXXXXXX.img)

dd if=$1 of=$TMPFILE bs=4M


if [[ -f $TARGET_FILE ]]; then
	read -p "The target file will be removed. Continue? [Y/n] " continueanswer

	case $continueanswer in
		[nN]*)
			exit;;
	esac
fi

mkdir $(dirname $TARGET_FILE)

tar -czf $TARGET_FILE $TMPFILE