cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

# Build the registry binary, prefix the image with build for easy removing if necessary
docker build -t build/registry: -f Dockerfile.build .

# Run the container
CID=$(docker run -d build/registry /bin/bash)

# Place binaries in the directory
rm -rf _bin
mkdir -p _bin

# Get the binary
docker cp $CID:/gopath/bin/registry _bin

# Build the real image
docker build -t luxas/registry:$LUX_VERSION .

docker rm $CID