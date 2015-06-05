#!/bin/bash

# This script is going to set up lucas amazing Raspberry Pi cloud service!
# This round is the Kubernetes round.
# We'll set up kubernetes common parts (used for both master and minion)
#
#
#
#
#
#
#
#
#

echo "Again, check how much free space we have on our system, for later comparision"
df -h

echo "Install compilation tools"
pacman -S gcc make --noconfirm

cd /
cd /lib/luxas

echo "Download go"
git clone https://go.googlesource.com/go
cd go

echo "Don't know why but i use go 1.4 anyway"
git checkout go1.4.1

cd src
./make.bash

## CHANGE THE PATH ##

# Should it be better to create a symlink?

echo "Add go binaries to PATH"
sed -e 's@PATH="@PATH="/lib/luxas/go/bin:@' -i /etc/profile

echo "Update our current PATH"
export PATH="$PATH:/lib/luxas/go/bin"

echo "Make GOPATH"
mkdir /lib/luxas/gopath

cat >> /etc/profile <<EOF

GOPATH="/lib/luxas/gopath"
export GOPATH
EOF

export GOPATH="/lib/luxas/gopath"


# To compile go took about 10 mins

## ETCD ##
echo "Time to hack with etcd, not always fun :)"

cd /lib/luxas

git clone https://github.com/coreos/etcd.git

echo "Build etcd binaries"
cd etcd
./build

echo "Make symlinks"
ln -s /lib/luxas/etcd/bin/* /usr/bin

# Etcd working dir
mkdir /var/lib/etcd

cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd server
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/etcd
ExecStart=/usr/bin/etcd --listen-client-urls="http://0.0.0.0:4001,http://0.0.0.0:2379" --listen-peer-urls="http://localhost:2380,http://localhost:7001" --advertise-client-urls 'http://0.0.0.0:2379,http://0.0.0.0:4001'

[Install]
WantedBy=multi-user.target
EOF


export ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:4001,http://0.0.0.0:2379"







