#!/bin/bash
# How this build works
# This is a replacement for the Makefile

cd "$( dirname "${BASH_SOURCE[0]}" )"

# Retrieve their dependencies
build_dep(){
    IMAGE=$1

    # Return if empty or scratch
    if [[ $IMAGE == "" || $IMAGE == "scratch" ]]; then
    	exit
    fi

    # Read additional dependencies, they always takes precedence
    if [[ -f ./$IMAGE/deps ]]; then

	    # Read every line and build it
	    for line in "$(cat ./$IMAGE/deps)"; do 
	    	build $line; 
	  	done
    fi


    # Check if there is an Dockerfile
    if [[ -f ./$IMAGE/Dockerfile ]]; then

      # Build the image that this image depends on from the dockerfile
      build $(cat ./$IMAGE/Dockerfile | grep "FROM " | awk '{print $2}' | grep -o "[^:]*" | grep "/")
    fi
}

# Build an image
build(){
	# Does that image exist?
    if [[ -z $(docker images | grep "$1" | grep "$LUX_VERSION") ]]; then

    	# First, build all this image's dependencies
        echo "To install: $1"
        build_dep "$1"

        # Only build if the image directory exists
        if [[ -d $1 ]]; then

	        # Then build the image itself
	        echo "Installing: $1"
	        time ./$1/build.sh

	        docker tag "$1" "$1":$LUX_VERSION
	   	fi
    else
        echo "Already installed: $1"
    fi
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
		export_images "$@"
		exit;;
	"import") 
		import_images "$@"
		exit;;
	"clean") 
		clean
		exit;;
esac

if [[ $# = 1 && -z $(echo $1 | grep "/") ]]; then
	build_prefix $1
elif [[ $# = 0 ]]; then
    usage
else
	for IMG in "$@"
	do
		build $IMG
	done
fi