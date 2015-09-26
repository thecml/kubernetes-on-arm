mountpartitions(){

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

	# Require mkfs.vfat
	require mkfs.vfat dosfstools

	# Make boot filesystem
	mkfs.vfat $PARTITION1 

	# Mount partition 1 to boot, for editing
	mount $PARTITION1 $BOOT

	# Make root filesystem, answer y to if we want to overwrite the ext4 partition
	mkfs.ext4 $PARTITION2 <<EOF
y
EOF

	# Mount partition 2 to root, for editing
	mount $PARTITION2 $ROOT
}