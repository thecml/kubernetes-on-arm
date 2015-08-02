#!/bin/bash
#
# This is a script for writing the latest Arch Linux ARM files to a SD Card
#
# Based on this tutorial
# http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
#
# Usage:
# sudo sh BuildArchLinuxARM.sh [your sd card here]
#
# IMPORTANT THINGS
# - The SD Card must be in form of /dev/sda or /dev/sdb NOT /dev/sda1
# - Must be run as root (or by placing sudo first)
# - I have used it on Raspbian,  haven't tested it on Arch Linux
#
# Lucas Käldström 2015 (c)


# pacman -S dotfstools wget








# Here, Arch Linux ARM have two files for downloading: ArchLinuxARM-rpi-latest.tar.gz and ArchLinuxARM-rpi-2-latest.tar.gz
# The user chooses between them by writing "rpi" (without quotes) or "rpi-2"
read -p "Specify which Raspberry Pi were talking about: Raspberry Pi 1 [rpi] or Raspberry Pi 2 [rpi-2]" rpi

# Make some variables                               Examples    
_part=$1                                          # /dev/sda 
_part1=${1}1                                      # /dev/sda1
_part2=${1}2                                      # /dev/sda2
TMPDIR=/tmp/archscript                              # /tmp/archscript
BOOT=$TMPDIR/boot                                  # /tmp/archscript/boot
_root=$TMPDIR/root                                  # /tmp/archscript/root
_filename=ArchLinuxARM-${rpi}-latest.tar.gz       # ArchLinuxARM-rpi-2-latest.tar.gz


# Make temp dirs
mkdir $TMPDIR $_boot $_root

echo "Tempdirectories made"

# Make boot filesystem
mkfs.vfat $_part1

# Mount partition 1 to boot, for editing
mount $_part1 $_boot

echo "FAT filesystem made"

# Make root filesystem
mkfs.ext4 $_part2

# Mount partition 2 to root, for editing
mount $_part2 $_root

echo "EXT4 filesystem made"


# Not sure why I have the first cd there, but anyway, go to temp dir
cd /
cd $TMPDIR

echo "Start getting Arch"

# Get the zipped file with everything from their site
wget http://archlinuxarm.org/os/$_filename

echo "Finished getting Arch"

echo "Begin tarring Arch"

# Go to root dir
cd $_root

# Untar the folders (bin, etc, usr, sbin... you know) from the downloaded file
# I´m using absolute paths to be sure
tar -zxf $TMPDIR/$_filename

echo "Untarred Arch"

echo "Syncing disks..."

# Sync everything, may take some seconds
sync

echo "Finished syncing"

# Get back to the temp dir
cd $TMPDIR

# Move everything in the folder boot to the partition boot
mv $_root/boot/* $_boot

echo "Moved boot to first partition"

# Clean up
# Unmount boot and root
umount $_boot $_root

# And remove them
rmdir $_boot $_root

echo "Unmounted and removed dirs"

# Check if the user wants the downloaded file, could be wasteful to throw it
read -p "Should the downloaded file be removed? [Y/n]" remove

# If we should remove it, remove. If not, move the file and then remove the temp dir
case $remove in
  [yY]* ) rm -r $TMPDIR
	  echo "Finished successfully!";;

  [nN]* ) read -p "Okay, where should I put it?" tarpath
	  mv $TMPDIR/$_filename $tarpath
	  rm -r $TMPDIR
	  echo "Finished successfully!";;
esac


# Were finished. Now, put the SD Card in to your Raspberry Pi and have fun!
# Thanks, Lucas Käldström