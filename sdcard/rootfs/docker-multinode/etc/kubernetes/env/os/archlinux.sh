os_install(){

    # Catch errors
    set -e

    # Update the system and use pacman to install all the packages
    pacman -Syu --noconfirm

    # Install git and some other required things
    pacman -S git bridge-utils iproute2 --noconfirm --needed

    # Download docker daemon
    curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/v0.6.3/docker-1.10.0 > /usr/bin/docker
    chmod +x /usr/bin/docker

    # Add the docker group, so the daemon starts
    groupadd docker

    # Download the systemd service file
    curl -sSL https://raw.githubusercontent.com/docker/docker/master/contrib/init/systemd/docker.service > /usr/lib/systemd/system/docker.service
    curl -sSL https://raw.githubusercontent.com/docker/docker/master/contrib/init/systemd/docker.socket > /usr/lib/systemd/system/docker.socket

    systemctl daemon-reload
    systemctl enable docker.service
}
