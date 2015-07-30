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


read -p "You are going to lose all your data on $1. Continue? [Y/n]" answer


# Here we "press" the keys in order, commanding fdisk to make a partition
case $answer in 
  [yY]* ) echo "Now $1 is going to be partitioned"
          /sbin/fdisk $1 <<EOF
o
p
n
p
1

+100M
t
c
n
p
2


w
EOF
	 echo "Partitions OK!";;
  * ) echo "Quitting..."
      exit;;
esac

# Here, Arch Linux ARM have two files for downloading: ArchLinuxARM-rpi-latest.tar.gz and ArchLinuxARM-rpi-2-latest.tar.gz
# The user chooses between them by writing "rpi" (without quotes) or "rpi-2"
read -p "Specify which Raspberry Pi were talking about: Raspberry Pi 1 [rpi] or Raspberry Pi 2 [rpi-2]" rpi

# Make some variables                               Examples    
_part=$1                                          # /dev/sda 
_part1=${1}1                                      # /dev/sda1
_part2=${1}2                                      # /dev/sda2
_tmp=/tmp/archscript                              # /tmp/archscript
_boot=${_tmp}/boot                                # /tmp/archscript/boot
_root=${_tmp}/root                                # /tmp/archscript/root
_filename=ArchLinuxARM-${rpi}-latest.tar.gz       # ArchLinuxARM-rpi-2-latest.tar.gz


# Make temp dirs
mkdir $_tmp $_boot $_root

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
cd $_tmp

echo "Start getting Arch"

# Get the zipped file with everything from their site
wget http://archlinuxarm.org/os/$_filename

echo "Finished getting Arch"

echo "Begin tarring Arch"

# Go to root dir
cd $_root

# Untar the folders (bin, etc, usr, sbin... you know) from the downloaded file
# I´m using absolute paths to be sure
tar -zxf $_tmp/$_filename

echo "Untarred Arch"

echo "Syncing disks..."

# Sync everything, may take some seconds
sync

echo "Finished syncing"

# Get back to the temp dir
cd $_tmp

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
  [yY]* ) rm -r $_tmp
	  echo "Finished successfully!";;

  [nN]* ) read -p "Okay, where should I put it?" tarpath
	  mv $_tmp/$_filename $tarpath
	  rm -r $_tmp
	  echo "Finished successfully!";;
esac


# Were finished. Now, put the SD Card in to your Raspberry Pi and have fun!
# Thanks, Lucas Käldström