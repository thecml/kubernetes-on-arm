#!/bin/bash

# Get version variables
source /version.sh

# Make it run on a RPi 1 too
export GOARM=6

# Go can't compile k8s v1.0.x https://github.com/kubernetes/kubernetes/issues/16229
# Haven't tested this
if [[ $GO_VERSION == "go1.5.1" && $K8S_VERSION == "v1.0"* ]]; then
	echo "using go 1.4.x, because of kubernetes#16229"
	export GOROOT=/goroot1.4
	export PATH=$(echo $PATH | sed -e "s@/goroot@/goroot1.4@")
fi

K8S_DIR="$GOPATH/src/k8s.io/kubernetes"
K8S_CONTRIB="$GOPATH/src/k8s.io/contrib"
ETCD_DIR="$GOPATH/src/github.com/coreos/etcd"
FLANNEL_DIR="$GOPATH/src/github.com/coreos/flannel"
REGISTRY_DIR="$GOPATH/src/github.com/docker/distribution"

# Make directories
mkdir -p 	/build/bin 										\
			$K8S_DIR										\
			$K8S_CONTRIB									\
			$GOPATH/src/github.com/GoogleCloudPlatform		\
			$ETCD_DIR 										\
			$FLANNEL_DIR 									\
			$REGISTRY_DIR

# Symlink /gopath/src/k8s.io/kubernetes and the old /gopath/src/github.com/GoogleCloudPlatform/kubernetes
ln -s /gopath/src/k8s.io/kubernetes /gopath/src/github.com/GoogleCloudPlatform/kubernetes

## ETCD ##
# Download a gzipped archive and extract
curl -sSL https://github.com/coreos/etcd/archive/$ETCD_VERSION.tar.gz | tar -C $ETCD_DIR -xz --strip-components=1
cd $ETCD_DIR

# Apply some 32-bit patches
if [[ $ETCD_VERSION == "v2.0"* || $ETCD_VERSION == "v0"* ]]; then
	echo "etcd =< v2.0.x needs patches"
	curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/raft.go.patch > raft.go.patch
	curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/server.go.patch > server.go.patch
	curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/watcher_hub.go.patch > watcher_hub.go.patch
	patch etcdserver/raft.go < raft.go.patch
	patch etcdserver/server.go < server.go.patch
	patch store/watcher_hub.go < watcher_hub.go.patch
fi

# Build etcd
./build

# Copy over the binaries
cp bin/* /build/bin


## FLANNEL ##
# Download a gzipped archive and extract
curl -sSL https://github.com/coreos/flannel/archive/$FLANNEL_VERSION.tar.gz | tar -C $FLANNEL_DIR -xz --strip-components=1
cd $FLANNEL_DIR

# And build dynamically
./build

# Copy over the binaries
cp bin/* /build/bin

### KUBERNETES ###
# Download a gzipped archive and extract
curl -sSL https://github.com/kubernetes/kubernetes/archive/$K8S_VERSION.tar.gz | tar -C $K8S_DIR -xz --strip-components=1
cd $K8S_DIR

## Patches for building Kubernetes
if [[ $K8S_VERSION == "v1.2"* || $K8S_VERSION == "v1.1"* ]]; then
	echo "Building a >= v1.1.x branch of kubernetes"

	# libcontainer ARM issue. That file is by default built only on amd64
	mv Godeps/_workspace/src/github.com/docker/libcontainer/seccomp/jump{_amd64,}.go
	sed -e "s@,amd64@@" -i Godeps/_workspace/src/github.com/docker/libcontainer/seccomp/jump.go

	# Patch the nsenter writer, this is fixed on master: #16969
	curl -sSL https://raw.githubusercontent.com/kubernetes/kubernetes/8c1d820435670e410f8fd54401906c3d387c2098/pkg/util/io/writer.go > pkg/util/io/writer.go
else
	echo "Building an old branch of kubernetes"
fi

# Build kubectl statically
export KUBE_STATIC_OVERRIDES="kubectl"

# Build only these two kubernetes binaries
./hack/build-go.sh \
	cmd/hyperkube \
	cmd/kubectl

# Copy over the binaries
cp _output/local/bin/linux/arm/* /build/bin

## PAUSE ##
cd $K8S_DIR/build/pause

# Build the binary
./prepare.sh

# Copy over the binaries
cp pause /build/bin

## KUBE2SKY ##
cd $K8S_DIR/cluster/addons/dns/kube2sky

# Build for arm, fixed on master, #18669
sed -e "s@GOARCH=amd64@GOARCH=arm@" -i Makefile

# Build the binary
make kube2sky

# Include in build result
cp kube2sky /build/bin


## SKYDNS ##
# Compile the binary statically, requires mercurial
#go get github.com/skynetservices/skydns
CGO_ENABLED=0 go get -a -installsuffix cgo --ldflags '-w' github.com/skynetservices/skydns

# And copy over it
cp /gopath/bin/skydns /build/bin


## IMAGE REGISTRY ##
# Download a gzipped archive and extract
curl -sSL https://github.com/docker/distribution/archive/$REGISTRY_VERSION.tar.gz | tar -xz -C $REGISTRY_DIR --strip-components=1
cd $REGISTRY_DIR/cmd/registry

GOPATH=$REGISTRY_DIR/Godeps/_workspace:$GOPATH go build

# include rados, oss and gce storage drivers (optional)
# apt-get install -y librados-dev apache2-utils
# go build --tags include_rados include_oss include_gcs -v

# And compile. This gopath hack may also be resolved by using godep
# this is much slower than above
#GOPATH=$REGISTRY_DIR/Godeps/_workspace:$GOPATH make -C $REGISTRY_DIR $REGISTRY_DIR/bin/registry 
# go get github.com/docker/distribution/cmd/registry

# Copy the binary
cp registry /build/bin


## K8S CONTRIB ##
curl -sSL https://github.com/kubernetes/contrib/archive/master.tar.gz | tar -xz -C $K8S_CONTRIB --strip-components=1

## LOAD BALANCER ##
cd $K8S_CONTRIB/service-loadbalancer

# Build the binary
make server

# Copy the binary
cp service_loadbalancer /build/bin

## EXECHEALTHZ ##
cd $K8S_CONTRIB/exec-healthz

# Build the binary
make server

# Copy over the binary
cp exechealthz /build/bin

## SCALE DEMO ##
cd $K8S_CONTRIB/scale-demo/aggregator

make aggregator

cp aggregator /build/bin

cd $K8S_CONTRIB/scale-demo/vegeta

# Build the binary
CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags '-w' -o loader
# make loader

cp loader /build/bin