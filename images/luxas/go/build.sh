cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

# Use the version file
cp ../../version.sh .

# Build the image
docker build -t luxas/go:$LUX_VERSION .

# Make the filesystem
CID=$(docker run -d luxas/go:$LUX_VERSION /bin/bash)

# Get go and gofmt
docker cp $CID:/goroot/bin .

# Kanske inte alltid finns
rm -rf _bin

# Rename the directory to the standard _bin
mv bin _bin

# Remove the intermediate image
docker rm $CID