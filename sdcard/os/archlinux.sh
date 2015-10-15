# Invoked by sdcard/write
initos(){
	case $MACHINENAME in
		rpi|rpi-2|parallella)
			writeplainos;;
		cubietruck)
			writecubiearch;;
		*)
			exit;;
	esac
}

writeplainos(){
	# Download
	curl -sSL -k http://archlinuxarm.org/os/ArchLinuxARM-${MACHINENAME}-latest.tar.gz | tar -xz -C $ROOT

	sync

	# Move /boot to separate partition
	mv $ROOT/boot/* $BOOT
}

# Invoked by sdcard/write
mountpartitions(){
	# Partition the sd card
	case $MACHINENAME in
		rpi|rpi-2|parallella)
			mounthelper 100;; # Make 100 MB fat partition for the RPi
		cubietruck)
			mountcubietruck;; # Mount the cubie
		*)
			echo "Other boards than rpi, rpi-2 and parallella is not supported. Exiting..."
			exit 1
	esac
}

# This helper
mounthelper(){
	# Here we "press" the keys in order, commanding fdisk to make a partition
	echo "Now $SDCARD is going to be partitioned"
/sbin/fdisk $SDCARD <<EOF
o
p
n
p
1

+${1}M
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

mountcubietruck(){
	/sbin/fdisk $SDCARD <<EOF
o
p
n
p
1
2048

w
EOF

	mkfs.ext4 $PARTITION2 <<EOF
y
EOF
	# Mount partition 2 to root, for editing
	mount $PARTITION2 $ROOT
}

writecubiearch(){
	curl -sSL -k http://archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz | tar -xz -C $ROOT

	sync

	wget http://archlinuxarm.org/os/sunxi/boot/cubietruck/u-boot-sunxi-with-spl.bin

	dd if=u-boot-sunxi-with-spl.bin of=$SDCARD bs=1024 seek=8

	wget http://archlinuxarm.org/os/sunxi/boot/cubietruck/boot.scr -O $ROOT/boot/boot.scr
}