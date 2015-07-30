cd "$( dirname "${BASH_SOURCE[0]}" )"

# First, build
docker build -t k8s/build .

# Then copy out the binaries
CID=$(docker run k8s/build)
BIN="../_bin"
OUT="$BIN/latest"

# If there is a latest version, move to build date
if [ -f "$OUT/version.sh" ]
then
	# Now is the variable $BUILD_DATE available, which is the latest build date
	source "$OUT/version.sh"

	# Move latest to build date
	mv $OUT $BIN/$BUILD_DATE
fi

# Create the latest dir
mkdir -p $OUT

# Copy over all binaries
docker cp $(CID):/build/bin/* $OUT

# Copy the versions file to our directory
cp ../../version.sh $OUT/version.sh

# And append the build date
echo -e "BUILD_DATE=\"$(date +%d%m%y_%H%M)\"" >> $OUT/version.sh


# Clean
#docker rm $(CID)
#docker rmi luxas/build-go