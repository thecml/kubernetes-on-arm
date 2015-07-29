# First, build
docker build -t luxas/kubebuild .

# Then copy out the binaries
CID=$(docker run luxas/kubebuild)
BIN='../../bin'
OUT=$BIN/latest

source $BIN/latest/version.sh
# NOW IS THE VARIABLE $DATE available, which is the latest build date

mv $BIN/latest $BIN/$DATE

rm -rf $OUT
mkdir -p $OUT

docker cp $(CID):/build/bin/* $OUT
cp ../versions.sh $OUT/versions.sh


#docker rm $(CID)
#docker rmi luxas/build-go