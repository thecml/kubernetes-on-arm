os_install(){

    # Catch errors
    set -e

    # Update the system and use pacman to install all the packages
    pacman -Syu --noconfirm

    # Install git and some other required things
    pacman -S git bridge-utils iproute2 docker --noconfirm --needed

    systemctl daemon-reload
    systemctl enable docker.service

    # Well, this doesn't work anyway :(
    cat >> /usr/lib/sysctl.d/99-k8s.conf <<-EOF
	net.ipv4.tcp_mtu_probing=1
	vm.swappiness = 10
	EOF
}
