BASE=("luxas/raspbian" "luxas/alpine" "luxas/archlinux")
DEPS=(
	# ON RASPBIAN
	"luxas/go:luxas/raspbian" 
	"luxas/nodejs:luxas/raspbian"

	# ON NODE
	"k8s/web:luxas/nodejs"

	# ON GO
	"luxas/dockviz:luxas/go" 
	"luxas/registry:luxas/go" 
	"k8s/build:luxas/go"

	# ON K8S BUILD
	"k8s/hyperkube:k8s/build"
	"k8s/flannel:k8s/build"
	"k8s/pause:k8s/build"
	"k8s/etcd:k8s/build luxas/alpine"

	# ON ARCH
	"luxas/docker-client:luxas/archlinux"

	# ON ALPINE
	"luxas/nginx:luxas/alpine"
)


build_dep(){
    IMAGE=$1

    # Return if empty
    if [[ $IMAGE == "" ]]; then
    	exit
    fi

    # If the $IMAGE is a base image, there aren't any dependencies
    if [[ $(containsElement "$IMAGE" "${BASE[@]}") ]]; then
        exit
    fi

    TOREPLACE="$IMAGE:"
    DEP=$(getElement "$TOREPLACE" "${DEPS[@]}")
    NEWBUILDS=$(echo ${DEP/$TOREPLACE/''})

    for BUILD in $NEWBUILDS; do
        build "$BUILD"
    done
}

# Build an image
build(){
	# Does that image exist?
    if [[ -z $(docker images | grep "$1") ]]; then

    	# First, build all this image's dependencies
        echo "To install: $1"
        build_dep "$1"

        # Then build the image itself
        echo "Installing: $1"
        ./$1/build.sh
    else
        echo "Already installed: $1"
    fi
}

getElement () {
  local e
  for e in "${@:2}"; do [[ "$e" =~ "$1" ]] && echo "$e"; done
  return 1
}
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

# Return if empty
if [[ $IMAGE == "" ]]; then
	echo "Nothing to install."
	exit
fi
build $1