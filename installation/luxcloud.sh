#!/bin/bash
# Use this to config the RPi
# Install the necessary packages


# Usage: 
# luxcloud install
# luxcloud (build|import)
# luxcloud setup

# luxcloud status
# luxcloud usage
# luxcloud upgrade?
# luxcloud version?

LUXDIR="/usr/local/bin/luxcloud"
CONFIG="$LUXDIR/config.sh"
source $CONFIG

usage(){
	echo "Usage: \n 1: luxcloud install \n 2: luxcloud (build|import [dir]) \n 3: luxcloud setup \n Then your done!"
}

install() {
	# Check that we haven't done this before
	checkstep 0

	# Check how much space there is now
	spaceused 0

	# Install all packages
	time $LUXDIR/install.sh

	# And after
	spaceused 1

	# Next is step 1
	writestep 1
}
build(){
	# Check that we should do this now
	checkstep 1

	# Check if the images directory is present, so we may build the images
	if [ -f "/lib/luxas/luxcloud/images"]
	then
		# Build them and record the time
		time make -C /lib/luxas/luxcloud/images
	else
		echo "You have to push the luxcloud source to the git directory. \n\n You may also use luxcloud import [dir] to populate images."
		exit 1
	fi

	# Check how much is now used
	spaceused 2

	# Next is step 2
	writestep 2
}

import(){
	# Check that we should do this now
	checkstep 1

	# Import every tar.gz? file in IMPORTDIR to docker
	IMPORTDIR=$1

	for IMAGE in $IMPORTDIR/*
	do
		docker load -i $IMPORTDIR/$IMAGE
	done
	
	# Check how much is now used
	spaceused 2

	# Next is step 2
	writestep 2
}

setup(){
	# Check that we should do this now
	checkstep 2

	# Setup kubernetes, (etcd) and flannel
	time $LUXDIR/k8s.sh

	# Check how much is now used
	spaceused 3

	# Next is step 3
	writestep 3
}

spaceused(){
	spaceused=$(df -h | grep root | awk '{print $3}')
	echo "SPACE_USED_$1='$spaceused' \n" >> $CONFIG
}

checkstep(){
	if [[ "$NEXT_STEP" = "$1" ]]
	then
		# OK
	elif [[ "$NEXT_STEP" = 3 ]]
		echo "You are done!"
		exit 1
	else
		echo "You have to run the scripts in right order. Check usage for more info."
		exit 1
	fi
}

writestep(){
	if [ -z "$NEXT_STEP" ]
	then
		#NEXT_STEP is unset, write to file
		echo "NEXT_STEP=$1 \n" > $CONFIG
	else
		# Read current step and write the new one
		sed -e "s@NEXT_STEP=$NEXT_STEP@NEXT_STEP=$1@" -i $CONFIG
	fi
}


case $1 in
	'install')
		install;;
	'build')
		build;;
	'import')
		import $2;;
	'setup')
		setup;;
	'status')
		status;;
	*)
		usage;;
esac