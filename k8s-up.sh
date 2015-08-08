#!/bin/bash

# Compile binaries and docker images

# Catch errors
trap 'exit' ERR


echo "Again, check how much free space we have on our system, for later comparision"
df -h

# Now we are in the current dir
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Make all images
make -C images



docker save k8s/etcd | system-docker load
docker save k8s/flannel | system-docker load