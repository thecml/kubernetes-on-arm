# Make the build dir
mkdir /build
mkdir /build/bin
cd /build

# Get version variables
source /version.sh

## ETCD ##

# Determine how to get files
if [ "$ETCD_VERSION" == "latest" ]
then
	# Download via git, this way were always in HEAD and on the master branch
	git clone https://github.com/coreos/etcd.git
else
	# Download a gzipped archive and extract, much faster
	curl -sSL -k https://github.com/coreos/etcd/archive/v$ETCD_VERSION.tar.gz | tar -C /build/etcd -xz
fi

cd etcd

# Apply some 32-bit patches
curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/raft.go.patch > raft.go.patch
curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/server.go.patch > server.go.patch
curl https://raw.githubusercontent.com/mkaczanowski/docker-archlinux-arm/master/archlinux-etcd/patches/watcher_hub.go.patch > watcher_hub.go.patch
patch etcdserver/raft.go < raft.go.patch
patch etcdserver/server.go < server.go.patch
patch store/watcher_hub.go < watcher_hub.go.patch

# Build etcd
./build

# Copy over the binaries
cp bin/* /build/bin

## /ETCD ##


cd /build

## FLANNEL ##

# Determine how to get files
if [ "$FLANNEL_VERSION" == "latest" ]
then
	# Download via git, this way were always in HEAD and on the master branch
	git clone https://github.com/coreos/flannel.git
else
	# Download a gzipped archive and extract, much faster
	curl -sSL -k https://github.com/coreos/flannel/archive/v$FLANNEL_VERSION.tar.gz | tar -C /build/flannel -xz
fi

cd flannel

# And build
./build

# Copy over the binaries
cp /bin/* /build/bin

## /FLANNEL ##

cd /build

### KUBERNETES ###

# Determine how to get files
if [ "$K8S_VERSION" == "latest" ]
then
	# Download via git, this way were always in HEAD and on the master branch
	git clone https://github.com/GoogleCloudPlatform/kubernetes.git
else
	# Download a gzipped archive and extract, much faster
	curl -sSL -k https://github.com/GoogleCloudPlatform/kubernetes/archive/v$K8S_VERSION.tar.gz | tar -C /build/kubernetes -xz
fi

cd kubernetes


# Build kubernetes binaries
./hack/build-go.sh

# Copy over the binaries
cp _output/local/bin/linux/arm/* /build/bin

## PAUSE ##

cd build/pause

# Build the binary
./prepare.sh

# Copy over the binary
cp pause /build/bin