#!/bin/bash

# Change to current directory and fail on errors
cd "$( dirname "${BASH_SOURCE[0]}" )"
trap "exit" ERR

# Get version information
source ../version

# Output usage if no args is present
usage(){
cat <<EOF
This will build an ARM Docker image in this directory.

Usage:
images/build.sh kubernetesonarm/etcd
--> etcd is based on luxas/alpine
----> builds luxas/alpine
--> etcd depends on binaries from kubernetesonarm/build. Specified in the images/kubernetesonarm/etcd/deps file.
----> will build kubernetesonarm/build
----> kubernetesonarm/build depends on luxas/go
------> will build luxas/go
------> luxas/go depends on luxas/raspbian
--------> builds luxas/raspbian
--------> luxas/raspbian depends on resin/rpi-raspbian. Pull from Docker Hub.

How does this script know which image another image depends on?
The script checks the Dockerfile!

If you have custom dependencies, specify that in a deps file next to the Dockerfile.
EOF
}


# Retrieve an image's dependencies
build_dep(){
    IMAGE=$1

    # Return if empty or scratch, those images have no deps
    if [[ $IMAGE == "" || $IMAGE == "scratch" ]]; then
    	exit
    fi

    # Read dependencies from the custom file, they always takes precedence
    if [[ -f ./$IMAGE/deps ]]; then

	    # Read every line and build it
	    for line in "$(cat ./$IMAGE/deps)"; do 
	    	build $line; 
	  	done
    fi


    # Check if there is an Dockerfile
    if [[ -f ./$IMAGE/Dockerfile ]]; then

      # Build the image that this image depends on from the Dockerfile
      build $(cat ./$IMAGE/Dockerfile | grep "FROM " | awk '{print $2}' | grep -o "[^:]*" | grep "/")
    fi
}

# Builds an image
build() {

	# Does that image exist?
    if [[ -z $(docker images | grep "$1" | grep "$VERSION") ]]; then

    	# First, build all this image's dependencies
        echo "To build: $1"
        build_dep "$1"

        # Then, build this image. Only build if the image directory exists, otherwise we assume it´s from Docker Hub
        if [[ -d $1 ]]; then

        	echo "Building: $1"

        	# If the directory hasn't a build.sh file, then a normal docker build is invoked
        	if [[ ! -f ./$1/build.sh ]]; then

    			docker build -t $1 $1
        	else
		        # Then build the image via the build file
		        time ./$1/build.sh
		    fi

		    # Tag the image with current version
	        docker tag "$1" "$1":$VERSION
	   	fi
    else
        echo "Already built: $1"
    fi
}

# If no args is specifyed, output usage
if [[ $# = 0 ]]; then
    usage
else
	# Otherwise, build every arg
	for IMG in "$@"; do
		build $IMG
	done
fi