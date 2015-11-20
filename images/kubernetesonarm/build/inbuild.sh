#!/bin/bash

# Make the build dir
mkdir -p /build/bin

# Get version variables
source /version.sh

# Make it run on a RPi 1 too
export GOARM=6

# Go can't compile k8s v1.0.x https://github.com/kubernetes/kubernetes/issues/16229
# Haven't tested this go switch
if [[ $GO_VERSION == "go1.5.1" && $K8S_VERSION == "v1.0"* ]]; then
	echo "using go 1.4.x, because of kubernetes#16229"
	export GOROOT=/goroot1.4
	export PATH=$(echo $PATH | sed -e "s@/goroot@/goroot1.4@")
fi


## ETCD ##

# Download a gzipped archive and extract, much faster
curl -sSL -k https://github.com/coreos/etcd/archive/$ETCD_VERSION.tar.gz | tar -C /build -xz
mv /build/etcd* /build/etcd

cd /build/etcd

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

# Download a gzipped archive and extract, much faster
curl -sSL -k https://github.com/coreos/flannel/archive/$FLANNEL_VERSION.tar.gz | tar -C /build -xz
mv /build/flannel* /build/flannel

cd /build/flannel

# And build
./build

# Copy over the binaries
cp bin/* /build/bin


### KUBERNETES ###

# Download a gzipped archive and extract, much faster
curl -sSL -k https://github.com/kubernetes/kubernetes/archive/$K8S_VERSION.tar.gz | tar -C /build -xz
mv /build/kubernetes* /build/kubernetes

cd /build/kubernetes


## PATCHES FOR K8S BUILDING

# Do not build these packages
# Now it should be much faster
if [[ $K8S_VERSION == "v1.2"* || $K8S_VERSION == "v1.1"* ]]; then
	echo "Building a >= v1.1.x branch of kubernetes"
	TOREMOVE=(
		"cmd/kube-proxy"
		"cmd/kube-apiserver"
		"cmd/kube-controller-manager"
		"cmd/kubelet"
		"cmd/kubemark"
		"cmd/linkcheck"
		"plugin/cmd/kube-scheduler"

		" kube-controller-manager"
		" kube-scheduler"
	)
	TOCHANGE=(
		's/ "\${KUBE_TEST_TARGETS\[@\]}"/ /'
		"s@ kube-apiserver@ kubectl@"
	)

	# libcontainer ARM issue. That file is by default built only on amd64
	mv Godeps/_workspace/src/github.com/docker/libcontainer/seccomp/jump{_amd64,}.go
	sed -e "s@,amd64@@" -i Godeps/_workspace/src/github.com/docker/libcontainer/seccomp/jump.go

	# Patch the nsenter writer, this is fixed on master: #16969
	sed -e "s@echo@printf@" -i pkg/util/io/writer.go
else
	echo "Building an old branch of kubernetes"
	TOREMOVE=(
		"cmd/kube-proxy"
		"cmd/kube-apiserver"
		"cmd/kube-controller-manager"
		"cmd/kubelet"
		"cmd/kubernetes"
		"plugin/cmd/kube-scheduler"

		" kube-apiserver"
		" kube-controller-manager"
		" kube-scheduler"
	)
	TOCHANGE=(
		's/ "\${KUBE_TEST_TARGETS\[@\]}"/ /'
		"s@ hyperkube@ kubectl@"
	)
fi

  
# Loop each and remove them
for STR in "${TOREMOVE[@]}"; do
	sed -e "s@ $STR@@" -i hack/lib/golang.sh
done

# loop each change and replace
for STR in "${TOCHANGE[@]}"; do
	sed -e "$STR" -i hack/lib/golang.sh
done

# Build kubernetes binaries
./hack/build-go.sh

# Copy over the binaries
cp _output/local/bin/linux/arm/* /build/bin

## PAUSE ##

cd build/pause

# Build the binary
./prepare.sh

# Copy over the binaries
cp pause /build/bin
#cp /gopath/bin/goupx /build/bin

## KUBE2SKY ##

cd /build/kubernetes/cluster/addons/dns/kube2sky

# Required for building this
# It makes the current kubernetes repo location accessible from the default gopath location
mkdir -p /gopath/src/github.com/GoogleCloudPlatform /gopath/src/k8s.io/
ln -s /build/kubernetes /gopath/src/github.com/GoogleCloudPlatform/kubernetes
ln -s /build/kubernetes /gopath/src/k8s.io/kubernetes

# Build for arm
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
REGISTRY_DIR=$GOPATH/src/github.com/docker/distribution

# Make the dir
mkdir -p $REGISTRY_DIR

# Download source
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


## KUBE UI ##

#cd /build

#curl -sSL https://github.com/kubernetes/kube-ui/archive/master.tar.gz | tar -xz
#mv kube-ui* kube-ui

#cd /build/kube-ui

#go get github.com/jteeuwen/go-bindata/...

#ln -s /build/kube-ui /gopath/src/k8s.io/kube-ui

#make kube-ui

#cp kube-ui /build/bin


## LOAD BALANCER ##

cd /build

curl -sSL https://github.com/kubernetes/contrib/archive/master.tar.gz | tar -xz
mv contrib* contrib


cd /build/contrib/service-loadbalancer

CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags '-w' -o service_loadbalancer ./service_loadbalancer.go ./loadbalancer_log.go

cp service_loadbalancer /build/bin

## EXECHEALTHZ ##

cd /build/contrib/exec-healthz

# Build the binary
make server

# Copy over the binary
cp exechealthz /build/bin