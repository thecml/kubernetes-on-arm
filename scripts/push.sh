#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/..

source scripts/common.sh

docker login

for IMAGE in ${IMAGES[@]}; do
    
    time docker push $IMAGE
done
