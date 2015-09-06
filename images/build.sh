#!/bin/bash
# How this build works
# This is a replacement for the Makefile

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
        time ./$1/build.sh
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

usage(){
cat <<EOF
This will build all our ARM docker images in this directory.

Usage:

./build.sh all (in no specific order)
./build.sh export [image] [image]... (make a tar file of images, name will be luxcloud_version)
./build.sh import [archive] (import all images in tar package)
./build.sh clean (remove all build/* images, which is used as temp images for building)
./build.sh [some prefix] (e.g. luxas, will build all images under ./luxas/)
./build.sh [image] [image]... (e. g. luxas/archlinux k8s/build. Images will build from left to right)
EOF
}


source dependencies.sh
source version.sh

build_all()
{
	for DIR in *
	do
		if [[ -d $DIR ]]; then
			build_prefix $DIR
		fi
	done
}

build_prefix()
{
	for IMG in $1/*
	do
		if [[ -d $IMG && $1/_bin != $IMG ]]; then
			build $IMG
		fi
	done
}


export_images()
{

}

import_images()
{

}

clean()
{
	for IMAGE in $(docker images | grep build/ | awk '{print $1}')
	do
		docker rmi -f $IMAGE
	done
}



case $1 in 
  	"all") 
		build_all
		exit;;
	"export") 
		export_images $@
		exit;;
	"import") 
		import_images $@
		exit;;
	"clean") 
		clean
		exit;;
esac

if [[ $# = 1 && -d ./$1 ]]; then
	build_prefix $1
else
	for IMG in "$@"
	do
		build $1
	done
fi