cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

cp ../../version.sh .

# First, build
docker build -t k8s/build:$(LUX_VERSION) .

# Then copy out the binaries
CID=$(docker run -d k8s/build /bin/bash)
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
mkdir -p $BIN $OUT

# Copy over all binaries, now the binaries are in _bin/latest/bin
docker cp $CID:/build/bin $OUT

# It shouldn't be like that, move everything to _bin/latest
mv $OUT/bin/* $OUT


# Copy the versions file to our directory
cp ../../version.sh $OUT/version.sh

# And append the build date
echo -e "\nBUILD_DATE=\"$(date +%d%m%y_%H%M)\"" >> $OUT/version.sh

rm -r $OUT/bin


# Clean
#docker rm $(CID)
#docker rmi luxas/build-go
