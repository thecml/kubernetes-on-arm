cd "$( dirname "${BASH_SOURCE[0]}" )"

# Should be run on Rpi Arch Linux host

#first, copy the pacman config
cp /etc/pacman.conf mkimage-arch-pacman.conf

# install compilation tools
pacman -S arch-install-scripts --noconfirm --needed

# build
./mkimage.sh