os_install(){

    # Catch errors
    set -e

    # Update the system and use pacman to install all the packages
    pacman -Syu --noconfirm

    # Install git and some other required things
    pacman -S git iproute2 docker --noconfirm --needed
}


os_upgrade(){
    pacman -Syu --noconfirm
}

os_post_install(){
    # When on Arch Linux, we've just installed docker, so reboot before use.
    systemctl stop system-docker docker
}
