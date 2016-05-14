#!/bin/bash

set -e

DOCKERFILE=Dockerfile
TARGET=armhf


for arg in "$@"
do
    case $arg in
        "arm64" )
           TARGET=arm64
           DOCKERFILE=Dockerfile.arm64;;
   esac
done

OUTPUT=${OUTPUT:-$PWD/output-$TARGET}

echo "Buildin binaries for ARM target" $TARGET
docker build -t build-k8s-on-amd64 -f $DOCKERFILE .

docker run --name=build-k8s-on-amd64 build-k8s-on-amd64 true

echo "Copying binaries to" $OUTPUT
docker cp build-k8s-on-amd64:/output $OUTPUT

echo "Cleaning up build..."
docker rm build-k8s-on-amd64
docker rmi build-k8s-on-amd64
echo "Done"
