#!/bin/bash

# This script is going to set up lucas amazing Raspberry Pi cloud service!
# This round is the Kubernetes round.
# We'll set up kubernetes common parts (used for both master and minion)
#
#
# Content:
# - build tools
# - go
#   - change path
# - etcd
# - flannel
# - kubernetes
#   - pause image
# - build base images

############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
############################################################################### DEPRECATED #####################################################################################
# I use docker images instead

trap 'exit' ERR


echo "Again, check how much free space we have on our system, for later comparision"
df -h

echo "Install compilation tools"
pacman -S gcc make patch linux-raspberrypi-headers upx --noconfirm



#### INSTALL GO, WHICH WILL POWER EVERYTHING ####

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
sed -e 's@PATH="@PATH="/lib/luxas/go/bin:/lib/luxas/gopath/bin@' -i /etc/profile

echo "Update our current PATH"
export PATH="$PATH:/lib/luxas/go/bin:/lib/luxas/gopath/bin"

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

echo "Downloading etcd version 2.0.4"
git clone https://github.com/coreos/etcd.git

echo "Build etcd binaries"
cd etcd

git checkout v2.0.4

# Apply some 32-bit patches
curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/raft.go.patch > raft.go.patch
curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/server.go.patch > server.go.patch
curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/watcher_hub.go.patch > watcher_hub.go.patch
patch etcdserver/raft.go < raft.go.patch
patch etcdserver/server.go < server.go.patch
patch store/watcher_hub.go < watcher_hub.go.patch

./build

echo "Make symlinks"
ln -s /lib/luxas/etcd/bin/* /usr/bin

# Etcd working dir
mkdir /var/lib/etcd


# Maybe some more args to etcd how to handle
# Important, no "" around the arguments!
cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd server
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/etcd
ExecStart=/usr/bin/etcd --listen-client-urls=http://0.0.0.0:4001,http://0.0.0.0:2379 --listen-peer-urls=http://localhost:2380,http://localhost:7001 --advertise-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001

[Install]
WantedBy=multi-user.target
EOF

# Etcd took about 2-3 mins to compile

## /ETCD ##

## FLANNEL ##

cd /lib/luxas

git clone https://github.com/coreos/flannel.git

cd flannel

./build


### KUBERNETES ###

echo "Download the awesome kubernetes!"

cd /lib/luxas

git clone https://github.com/GoogleCloudPlatform/kubernetes.git

cd kubernetes


# git checkout [version]




# BUILD PAUSE IMG #

# The pause img isn't working by default it's amd64 version
# Let's build our own
cd build/pause

# go get github.com/pwaller/goupx
# go install github.com/pwaller/goupx

./prepare.sh

docker build -t luxas/pause .

# /BUILD PAUSE IMG #





# remember to put --pod_infra_container_image="luxas/pause" on kubelet
# apiserver ip = 0.0.0.0
# apiserver --cors_allowed_origins=.*
# is it a must to remove sudo -E? YES
hack/local-up-cluster.sh

# -------->>>>>>>>>>>>> own thread

# Took about 10 min

### /KUBERNETES ###


## BUILDING BASE IMAGES ##

### Solve this path

./images/alpine/build.sh
echo "Now our base image is built! 8.5 MB"

## /BUILDING BASE IMAGES ##


## WEB SERVER ##
# This should be in a docker container

pacman -S nodejs npm --noconfirm

npm install -g bower http-server

cd www/master

npm install



# SETUP DEVELOPMENT ENVIROINMENT

cd shared/config



cd ../..

npm start

# ----------->>>>>>>>>>>>>> own gulp thread


# start web server
cd www/app
http-server -a 0.0.0.0 -p 8000

# ---------->>>>>>>>>>> own www thread


## KUBERNETES WEB MODS ##

sed -e 's@bower install"@bower install --allow-root"@' -i www/master/package.json

cp www/master/shared/config/development.example.json www/master/shared/config/development.json

sed -e 's@"k8sApiServer": "/api/v1beta3"@"k8sApiServer": "http://localhost:8080/api/v1"@' -i www/master/shared/config/development.json
sed -e 's@"cAdvisorProxy": ""@"cAdvisorProxy": "http://192.168.1.55:8080/api/v1/proxy/nodes/"@' -i www/master/shared/config/development.json



# TODO Dockerize etcd, flanneld and kubernetes master components
# TODO Dockerize web server
# TODO Eventually build own docker binary
# TODO System-docker
# TODO Use salt