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
	- Write an os to a sd card
	- Customize for a specific type of board (e. g. rpi, banana pi)
	- Insert files and configuration via a a prepopulated rootfs, so your os works out-of-the-box!

Required arguments:

sdcard/write.sh [disc or sd card] [boot] [os]

Optional argument:

sdcard/write.sh [disc or sd card] [boot] [os] [rootfs]

Explanation:
	disc - The SD Card place, often /dev/sdb or something. Run 'fdisk -l' to see what letter you sd card have.
	boot - The type of board you have, e. g. a Raspberry Pi. That RPi requires special boot files.
	os - The operating system which should be downloaded and installed.
	rootfs - Prepopulated rootfs with scripts and such.

All input should have corresponding files, folders or discs.

Example:
sdcard/write.sh /dev/sdb rpi-2 archlinux kube-archlinux

EOF
}


# Catch errors
trap 'exit' ERR

# cd to current dir ~/sdcard
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Get access to current version
source ../images/version.sh

########################## SECURITY CHECKS ##############################

# Root is required
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
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
if [[ -z $(fdisk -l | grep "$1") ]] 
then
	echo "The disc $1 doesn't exist. Compare with 'fdisk -l'"
	exit 1
fi

########################## OPTIONS ##############################

# /dev/sdb, /dev/sdb1, /dev/sdb2
SDCARD=$1
PARTITION1=${1}1
PARTITION2=${1}2

# A tmp dir to store things in, a boot partition and the root filesystem
TMPDIR=/tmp/writesdcard
BOOT=$TMPDIR/boot
ROOT=$TMPDIR/root
PROJROOT=./..

if [[ -z $QUIET ]]; then

	# Security check
	read -p "You are going to lose all your data on $1. Continue? [Y/n]" answer

	case $answer in 
	  	[yY]* ) 
			echo "OK. Continuing...";;

		* ) 
			echo "Quitting..."
	      	exit 1;;
	esac
fi

########################## SOURCE FILES ##############################

# Make some temp directories
mkdir -p $TMPDIR $BOOT $FILES

MACHINENAME=$2
OSNAME=$3
ROOTFSNAME=$4

# Populate rootfs
if [[ -d rootfs/$ROOTFSNAME ]]; then

	# Prepopulate the rootfs
	cp -r rootfs/$ROOTFSNAME $ROOT

	# If we've a dynamic rootfs, invoke it
	if [[ -f $ROOT/dynamic-rootfs.sh ]]; then
		
		# Source the dynamic rootfs script
		source $ROOT/dynamic-rootfs.sh
	fi
fi

# Ensure they exists	
if [[ ! -f boot/$MACHINENAME.sh || ! -f os/$OSNAME.sh ]]; then
	echo "boot/$MACHINENAME.sh or os/$OSNAME.sh not found. These files are required. Exiting..."
	exit
fi

# Source machine and os
source boot/$MACHINENAME.sh
source os/$OSNAME.sh


# MACHINE must provide:
# mountpartitions()

# OS must provide:
# initos()

# Mount them
mountpartitions

echo "Partitions mounted"

# Download a tar file and extract it, requires $MACHINENAME
initos

echo "OS written to SD Card"

# And invoke the function
rootfs

# Remove the intermediate file
rm $ROOT/dynamic-rootfs.sh

# Clean up
# Unmount boot and root
umount $BOOT $ROOT

# Remove the temp filesystem
rm -r $TMPDIR