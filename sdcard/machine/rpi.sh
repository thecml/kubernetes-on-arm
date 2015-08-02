# Populate $MACHINENAME
read -p "Specify which Raspberry Pi were talking about: Raspberry Pi 1 [rpi] or Raspberry Pi 2 [rpi-2]" MACHINENAME


mkpartitions(){
	# Here we "press" the keys in order, commanding fdisk to make a partition
	echo "Now $SDCARD is going to be partitioned"
/sbin/fdisk $SDCARD <<EOF
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
	echo "Partitions OK!"
}


mountpartitions(){
	# Make boot filesystem
	mkfs.vfat $PARTITION1

	# Mount partition 1 to boot, for editing
	mount $PARTITION1 $BOOT

	# Make root filesystem
	mkfs.ext4 $PARTITION2

	# Mount partition 2 to root, for editing
	mount $PARTITION2 $ROOT
}  




unmountpartitions(){
	# Clean up
	# Unmount boot and root
	umount $BOOT $ROOT
}