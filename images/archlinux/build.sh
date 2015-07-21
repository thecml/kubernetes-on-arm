# Should be run on Rpi Arch Linux host

#first, copy the pacman config
cp /etc/pacman.conf mkimage-arch-pacman.conf

# install compilation tools
pacman -S arch-install-scripts expect --noconfirm


#specify our arch which isnt arm71 but armv7h for pacman config
sed -e 's@$arch@armv7h@' -i mkimage.sh

# build
./mkimage.sh