cd "$( dirname "${BASH_SOURCE[0]}" )"


docker build -t luxas/dockviz .

CID=$(docker run -d luxas/dockviz /bin/bash)

docker cp $CID:/dockviz-master/dockviz /usr/bin