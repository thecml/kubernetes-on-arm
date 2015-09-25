cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

# Start the build
docker build -t build/dockviz .

# Make the filesystem
CID=$(docker run -d build/dockviz /bin/bash)

# Create a binary directory, ignore previous builds
rm -rf _bin
mkdir -p _bin

# Get the binary
docker cp $CID:/dockviz-master/dockviz _bin

# Install to our system
cp _bin/dockviz /usr/bin

# Remove the intermediate container
docker rm $CID