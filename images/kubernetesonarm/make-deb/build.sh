cd "$( dirname "${BASH_SOURCE[0]}" )"

# First, build
docker build -t kubernetesonarm/make-deb .

CID=$(docker run -d kubernetesonarm/make-deb /bin/bash)

docker cp $CID:/build-deb .

mkdir -p ../_debs

mv -f build-deb/*.deb ../_debs

rm -r build-deb

docker rm $CID