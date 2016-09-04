# This command is run by kube-config when doing "kube-config install"
board_install(){
    export INSTALL_STORAGE_DRIVER=aufs

    # Install docker if it doesn't exist
    if [[ ! -f $(which docker 2>&1) ]]; then

        apt-get update && apt-get install -y bridge-utils iptables

        curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/v0.6.3/docker-1.10.0 > /usr/bin/docker
        chmod +x /usr/bin/docker

        groupadd -f docker

        curl -sSL https://raw.githubusercontent.com/docker/docker/v1.12.1/contrib/init/systemd/docker.service > /lib/systemd/system/docker.service
        curl -sSL https://raw.githubusercontent.com/docker/docker/v1.12.1/contrib/init/systemd/docker.socket > /lib/systemd/system/docker.socket

        sed -e "s|ExecStart=/usr/bin/dockerd -H fd://|ExecStart=/usr/bin/docker daemon -H fd://|" -i /lib/systemd/system/docker.service

        systemctl daemon-reload
        systemctl enable docker
    fi
}
