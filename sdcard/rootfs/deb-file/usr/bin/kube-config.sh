#!/bin/bash

LATEST_DOWNLOAD_RELEASE="v0.7.0"

usage(){
    cat <<EOF
Welcome to kube-config lite!

With this utility, you can setup Kubernetes on ARM!

Usage: 
    kube-config install - Downloads the latest .deb package and installs it. This script will be replaced with the real one after the installation

EOF
}


# Root is required
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  usage
  exit 1
fi

install(){

	echo "Downloading kube-systemd.deb..."
	curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/$LATEST_DOWNLOAD_RELEASE/kube-systemd.deb > /tmp/kube-systemd.deb

	echo "Installing Kubernetes on ARM..."
	dpkg -i /tmp/kube-systemd.deb

	echo "Running kube-config install as usual..."
	mv /usr/bin/kube-config{,_lite}
	kube-config install
}

# If nothing is specified, return usage
if [[ $# == 0 ]]; then
    usage
    exit
fi

# Commands available
case $1 in
    'install')
        install;;
    'help')
        usage;;
    *) 
        usage;;
esac
