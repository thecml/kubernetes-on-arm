cd "$( dirname "${BASH_SOURCE[0]}" )"

docker build -t luxas/go .

CID=$(docker run luxas/go /bin/echo "Hello")

docker cp $CID:/goroot/bin/* _bin

docker rm $CID