cd "$( dirname "${BASH_SOURCE[0]}" )"

# Build the alpine on the host
./mkimage.sh

# Get the rootfs archive
mv /tmp/rootfs.tar.xz .

# Build the real image
docker build -t luxas/alpine .

rm rootfs.tar.xz