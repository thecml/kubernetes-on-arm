cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../../version.sh .

docker build -t luxas/go .

CID=$(docker run -d luxas/go)

docker cp $CID:/goroot/bin .

rm -r _bin
mv bin _bin

#docker rm $CID