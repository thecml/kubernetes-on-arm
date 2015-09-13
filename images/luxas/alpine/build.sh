cd "$( dirname "${BASH_SOURCE[0]}" )"

# Build the alpine image
# Download the base image
#curl -sSL -k https://github.com/luxas/alpine-arm/archive/master.tar.gz | tar -xz

# Edit some scripts in this dir
#cd alpine-arm-master/rootfs

# Change to a debian arm version and hardcode the "armhf" because uname -m gives armv71 which no pkg managers recognize
#sed -e "s@ubuntu-debootstrap:14.04@resin/rpi-raspbian@" -i Dockerfile
#sed -e "s@$(uname -m)@'armhf'@" -i mkimage.sh

# Build the image to rootfs.tar.xz
# TODO: this will eventually create a new, unnecessary image
#make

# Step up and compile that rootfs.tar.xz image to a docker image
#cd ..

# Build the alpine image
#docker build -t luxas/alpine .

#docker rmi base-rootfs

#rm -r base

source ../../version.sh

# Build the alpine on the host
./mkimage.sh

# Get the rootfs archive
mv /tmp/rootfs.tar.xz .

# Build the real image
docker build -t luxas/alpine:$(LUX_VERSION) .

rm rootfs.tar.xz