#!/bin/bash

### PART 1: GATHER FILES

cd /kubernetes-on-arm

# Export paths required for the dynamic-rootfs script
export PROJROOT=$(pwd)	
export ROOT=$(mktemp -d /tmp/make-deb.XXXX)	

# Copy kube-archlinux source to /tmp
cp -r $PROJROOT/sdcard/rootfs/kube-archlinux/* $ROOT 

source $ROOT/dynamic-rootfs.sh	
cd sdcard

# Invoke the function that customizes the kube-archlinux with symlinks and stuff
rootfs

# That file is temporary
rm $ROOT/dynamic-rootfs.sh


### PART 2: MAKE DEB
# Inspired by: https://github.com/hypriot/rpi-docker-builder/blob/master/builder.sh

# Get uncompressed size and get the $VERSION variable
filesize=`du -sk $ROOT | cut -f1`
source $PROJROOT/version

# Make control file
mkdir $ROOT/DEBIAN
cat > $ROOT/DEBIAN/control <<EOF
Package: $PACKAGE_NAME
Version: $VERSION$PACKAGE_REVISION
Architecture: $PACKAGE_ARCH
Maintainer: Lucas Kaldstrom <lucas.kaldstrom@hotmail.co.uk>
Installed-Size: $filesize
Recommends: ca-certificates, cgroupfs-mount, git, systemd, iptables | cgroup-lite, xz-utils
Section: admin
Priority: optional
Homepage: https://github.com/luxas/kubernetes-on-arm
Description: Kubernetes for ARM devices
EOF													

# Generate MD5 checksums
(cd $ROOT; find . -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums) && \

# Make target dir
mkdir /build-deb

# The package process
fakeroot dpkg -b $ROOT /build-deb/

# Output info
echo "Package size (uncompressed): $filesize kByte"		
echo "The package is here:"	
ls -l /$PACKAGE_NAME*