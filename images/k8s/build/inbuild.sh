# Make the build dir
mkdir /build
mkdir /build/bin
cd /build

## ETCD ##

# Download and use v2.0.4
git clone https://github.com/coreos/etcd.git
cd etcd

git checkout v2.0.4

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

cd /build

## FLANNEL ##

# Download flannel
git clone https://github.com/coreos/flannel.git
cd flannel

# And build
./build

# Copy over the binaries
cp /bin/* /build/bin

cd /build

### KUBERNETES ###

# Download latest
git clone https://github.com/GoogleCloudPlatform/kubernetes.git
cd kubernetes

# Use latest stable version
git checkout v1.0.1

# Build kubernetes binaries
./hack/build-go.sh

# Copy over the binaries
cp _output/local/bin/linux/arm/* /build/bin