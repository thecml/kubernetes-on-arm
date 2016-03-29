source common.sh

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

    echo "Downloading images from Github and loading them to docker"
    curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/v0.7.0/images.tar.gz | gzip -dc | docker load
    echo "Finished loading them to docker"
}


# This is a perf benchmark between docker pull and docker load from Github
time docker rmi $(docker images -q)
time require-images ${IMAGES[@]}
docker images
time docker rmi $(docker images -q)
time dl_github
docker images
