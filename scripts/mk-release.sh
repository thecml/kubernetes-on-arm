#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/..


# Move to an USB or a folder
if [[ $# == 1 ]]; then

	# But, first package binaries
	scripts/package.sh

	BUILDDIR=release/latest
	OUTDIR=$1

	# If the target is a partition
	if [[ $(fdisk -l | grep $1 | wc -l) == 1 && $1 == "/dev/"* ]]; then

		DIR=$(mktemp -d /tmp/package-k8s.XXXXXX)

		mount $1 $DIR

		OUTDIR="$DIR/$(date +%d%m%y_%H%M)"
		
	fi

	mkdir -p $OUTDIR

	cp $BUILDDIR/* $OUTDIR


	if [[ ! -z $DIR ]]; then
		umount $DIR
		rm -r $DIR
	fi
else
fi