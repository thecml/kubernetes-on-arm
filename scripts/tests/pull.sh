K8S_PREFIX="kubernetesonarm"
REQUIRED_MASTER_IMAGES=("$K8S_PREFIX/flannel $K8S_PREFIX/etcd $K8S_PREFIX/hyperkube $K8S_PREFIX/pause $K8S_PREFIX/skydns $K8S_PREFIX/kube2sky $K8S_PREFIX/exechealthz $K8S_PREFIX/registry")

require-images(){
    local FAIL=0

    # Loop every image, check if it exists
    for IMAGE in "$@"; do
            if [[ -z $(docker images | grep "$IMAGE") ]]; then

                    # If it doesn't exist, try to pull
                    echo "Pulling $IMAGE from Docker Hub"
                    docker pull $IMAGE
                    
                    if [[ -z $(docker images | grep "$IMAGE") ]]; then

                            echo "Pull failed. Try to pull this image yourself: $IMAGE"
                            FAIL=1
                    fi
            fi
    done

    if [[ $FAIL == 1 ]]; then
            echo "One or more images failed to pull. Exiting...";
            exit 1
    fi
}

dl_github(){
    if [[ -d /tmp/downloadk8s ]]; then
            rm -rf /tmp/downloadk8s
    fi

    # Make the directory
    mkdir -p /tmp/downloadk8s

    echo "Downloading images from Github"
    # Get the uploaded archive
    curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/v0.5.5/images.tar.gz | tar -xz -C /tmp/downloadk8s

    echo "Loading them to docker"
    # And load it to docker
    docker load -i /tmp/downloadk8s/images.tar

    echo "Finished loading them to docker"

    # And remove the temp
    rm -r /tmp/downloadk8s
}


# MAIN
time docker rmi $(docker images -q)
time require-images ${REQUIRED_MASTER_IMAGES[@]}
docker images
time docker rmi $(docker images -q)
time dl_github
docker images