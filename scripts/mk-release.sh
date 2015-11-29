#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/..

PACKAGE=${PACKAGE:-1}

# Move to an USB or a folder
if [[ $# == 1 ]]; then

    # But, first package binaries
    if [[ $PACKAGE == 1 ]]; then

		echo "Packaging artifacts..."
        scripts/package.sh
    fi

    BUILDDIR=release/latest
    OUTDIR=$1

    # If the target is a disc
    if [[ $1 == "/dev/"* ]]; then

    	DIR=$(mktemp -d /tmp/package-k8s.XXXXXX)

	    if [[ $(fdisk -l | grep $1 | wc -l) == 1 ]]; then

	        echo "Using partition $1"
	        mount $1 $DIR
	    else
	    	echo "Using partition ${1}1"
	        mount ${1}1 $DIR
	    fi

	   	OUTDIR="$DIR/kubernetesonarm_$(date +%d%m%y_%H%M)"
	fi

    mkdir -p $OUTDIR

    echo "Copying files..."
    cp $BUILDDIR/* $OUTDIR

    if [[ ! -z $DIR ]]; then
    	echo "Unmounting the disc"
        umount $DIR
        rm -r $DIR
    fi
else
	cat <<EOF
Packages Kubernetes images, binaries and kubectl to a target

Usage:
PACKAGE=(1=default|0) scripts/mk-release.sh [disc or partition or absolute path]

Examples:
PACKAGE=0 scripts/mk-release.sh /dev/sda2
PACKAGE=1 scripts/mk-release.sh /dev/sda [/dev/sda1 automatically chosen]
scripts/mk-release.sh /etc/k8s-artifacts
EOF
fi