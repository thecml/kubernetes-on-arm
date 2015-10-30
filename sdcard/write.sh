#!/bin/bash

########################## HELPER ##############################

# Install a package 
require()
{
	BINARY=$1
	PACKAGE=$2

	# If the $BINARY path -e(xists)
	if [[ ! -e $(which $BINARY) ]]; then
		
		if [[ -e $(which pacman) ]]; then # Is pacman present?
			pacman -S $PACKAGE --noconfirm
			
		elif [[ -e $(which apt-get) ]]; then # Is apt-get present?
			apt-get install -y $PACKAGE
		else
			echo "The required package $PACKAGE with the binary $BINARY isn't present now. Install it."
			exit 1
		fi
	fi
}

########################## USAGE ##############################

usage(){
	cat <<EOF
Welcome to the write to sd card process!
This script will allow you to:
	- Write an os to a SD Card
	- Customize for a specific type of board
	- Insert files and configuration via a a prepopulated rootfs, so your os works out-of-the-box!

Required arguments:

sdcard/write.sh [disc or sd card] [boot] [os]

Optional argument:

sdcard/write.sh [disc or sd card] [boot] [os] [rootfs]

Explanation:
	disc - The SD Card place, often /dev/sdb or something. Run 'fdisk -l' to see what letter you sd card have.
	boot - The type of board you have
		- Currently supported:
			- rpi - For Raspberry Pi A, A+, B, B+
			- rpi-2 - For Raspberry Pi 2 Model B
			- parallella - The Adepteva Parallella board. Note: Awfully slow. Do not use as-is. But you're welcome to hack and improve it. Should have a newer kernel
			- cubietruck - Feel free to test and return bugs. @luxas doesn't have a cubie, so he can't test it.
	os - The operating system which should be downloaded and installed.
		- Currently supported:
			- archlinux - Arch Linux ARM
	rootfs - Prepopulated rootfs with scripts and such.
		- Currently supported: 
			- kube-archlinux - Kubernetes scripts prepopulated (optional)

Example:
sdcard/write.sh /dev/sdb rpi-2 archlinux kube-archlinux
EOF
}


# Catch errors
trap 'exit' ERR

# cd to current dir ~/sdcard
cd "$( dirname "${BASH_SOURCE[0]}" )"

########################## SECURITY CHECKS ##############################

# Root is required
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  usage
  exit 1
fi

# At least three arguments should be present
if [[ "$#" < 3 ]]; then
	echo "You must specify at least three arguments."
	usage
	exit 1
fi

# Require fdisk to be installed
require fdisk fdisk

# Check that it really is a disk
if [[ -z $(fdisk -l | grep "$1") ]]; then
	echo "The disc $1 doesn't exist. Check with 'fdisk -l'"
	exit 1
fi

########################## OPTIONS ##############################

# /dev/sdb, /dev/sdb1, /dev/sdb2
SDCARD=$1

# Special case. the mmcblk0 disc's partitions are named p1 and p2 instead of 1 and 2 
if [[ $SDCARD == "/dev/mmcblk"* ]]; then
	PARTITION1=${1}p1
	PARTITION2=${1}p2	
else
	PARTITION1=${1}1
	PARTITION2=${1}2
fi

# A tmp dir to store things in, a boot partition and the root filesystem
# TODO: use mktemp... instead of hard-coded dir
TEMPDIR=$(mktemp /tmp/writesdcard.XXXXXXXX)
BOOT=$TMPDIR/boot
ROOT=$TMPDIR/root
PROJROOT=./..
LOGFILE=/tmp/kubernetes-on-arm.log
CUSTOMCMDFILETMP=$TMPDIR/customcmd
CUSTOMCMDFILETARGET=etc/customcmd.sh

MACHINENAME=$2
OSNAME=$3
ROOTFSNAME=$4


if [[ -z $QUIET || $QUIET == 0 ]]; then

	# Security check
	read -p "You are going to lose all your data on $1. Continue? (Y is default) [Y/n]" answer

	case $answer in 
	  	[nN]*) 
			echo "Quitting..."
			rm -r $TMPDIR
	      	exit 1;;		
	esac

	# OK to continue
	echo "OK. Continuing..."
fi

########################## SOURCE FILES ##############################

# Make some temp directories
mkdir -p $ROOT $BOOT

# Ensure they exists	
if [[ ! -f os/$OSNAME.sh ]]; then
	echo "os/$OSNAME.sh not found. That file is required. Exiting..."
	rm -r $TMPDIR
	exit 1
fi

# Copy the contents of the command file to the temp command file
if [[ -f os/$OSNAME/commands.sh ]]; then
	cat os/$OSNAME/commands.sh >> $CUSTOMCMDFILETMP
fi

# Copy the contents of the custom board file to the temp command file
if [[ -f os/$OSNAME/$MACHINENAME.sh ]]; then
	cat os/$OSNAME/$MACHINENAME.sh >> $CUSTOMCMDFILETMP
fi

# Source machine and os
source os/$OSNAME.sh

# OS must provide:
# initos()
# mountpartitions()

# Mount them
mountpartitions

echo "Partitions mounted"

# Populate rootfs
if [[ -d rootfs/$ROOTFSNAME ]]; then

	# Prepopulate the rootfs
	cp -r rootfs/$ROOTFSNAME/* $ROOT

	# If we've a dynamic rootfs, don't invoke it, but load it
	if [[ -f $ROOT/dynamic-rootfs.sh ]]; then
		
		# Source the dynamic rootfs script
		source $ROOT/dynamic-rootfs.sh
	fi
fi

echo "Downloading OS and writing to SD Card"

# Download a tar file and extract it, requires $MACHINENAME
initos

echo "OS written to SD Card"

# And invoke the function
rootfs

# Write the custom cmd file
mv $CUSTOMCMDFILETMP $ROOT/$CUSTOMCMDFILETARGET

# Remove the intermediate file
rm $ROOT/dynamic-rootfs.sh

# Clean up
# Unmount boot and root, call the os file
cleanup

# Remove the temp filesystem
rm -r $TMPDIR

echo "Finished writing your SD Card."