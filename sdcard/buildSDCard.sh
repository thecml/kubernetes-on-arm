
# buildSDCard.sh [disc] [machine] [distro] [middleware] [middleware-parameter]
# buildSDCard.sh /dev/sdb rpi archlinux luxcloud-master pimaster 


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# Security check
read -p "You are going to lose all your data on $1. Continue? [Y/n]" answer

case $answer in 
  	[yY]* ) 
		echo "OK. Continuing...";;

	* ) 
		echo "Quitting..."
      	exit 1;;
esac



# /dev/sdb, /dev/sdb1, /dev/sdb2
SDCARD=$1
PARTITION1=${1}1
PARTITION2=${1}2

# A tmp dir to store things in, a boot partition and the root filesystem
TMPDIR=/tmp/writesdcard
BOOT=$TMPDIR/boot
ROOT=$TMPDIR/root

# Make some temp directories
mkdir $TMPDIR $BOOT $ROOT

# The files to source
MACHINE=./machine/$2.sh
DISTRO=./distro/$3.sh
MIDDLEWARE=./middleware/$4.sh
MIDDLEWARE_PARAM=$5

# If machine doesn't exist
if [ ! -f "$MACHINE" ]
then
	echo "You must specify the machine type in the second argument. Example: rpi"
	exit 1
fi

# If the distro doesn't exist
if [ ! -f "$DISTRO" ]
then
	echo "You must specify the distro in the third argument. Example: archlinux"
	exit 1
fi

# Use our files, which will do the job
source $MACHINE
source $DISTRO


# $MACHINE must provide:
# $MACHINENAME = (rpi|rpi-2)
# mkpartitions()
# mountpartitions()
# unmountpartitions()


# $DISTRO must provide:
# dlandextract()
# populateboot()


# $MIDDLEWARE must provide:
# domiddleware()

# Make partitions
mkpartitions

# Mount them
mountpartitions

# Download a tar file and extract it, requires $MACHINENAME
dlandextract

# Sync the filesystem
sync

# Fill the boot partition with some useful bootloader
populateboot


# If we specified middleware, run it
if [ -f "$MIDDLEWARE" ]
then
	source $MIDDLEWARE
	domiddleware
fi

# Unmount the temp filesystem
unmountpartitions

# Remove the temp filesystem
rm -r $TMPDIR