#!/bin/bash
# Use this to config the luxcloud node
# Install the necessary packages


# Usage: 
# luxcloud install
# luxcloud (build|import|get)
# luxcloud setup

# luxcloud edit

# luxcloud export

# luxcloud stats
# luxcloud usage
# luxcloud upgrade?
# luxcloud version?

LUXDIR="/usr/local/bin/luxcloud"
CONFIG="$LUXDIR/config.sh"
source $CONFIG

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# Error handler
trap 'exit' ERR

usage(){
	cat <<EOF
	Usage: 
	 1: lux install 
	 2: lux (build|import [dir])
	 3: lux setup 
	Then your done!
EOF
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

	# Reboot for changes to take effect, IS REQUIRED FOR DOCKER TO FUNCTION
	echo "Rebooting..."
	reboot
}
build(){

	if [[ $# = 0 &&  -d "/lib/luxas/luxcloud/images" ]]; then
        /lib/luxas/luxcloud/images/build.sh
    fi
	# Check that we should do this now
	checkstep 1

	# Check if the images directory is present, so we may build the images
	if [ -d "/lib/luxas/luxcloud/images" ]
	then
		# Build them and record the time
		time /lib/luxas/luxcloud/images/build.sh $1
	else
		echo -e "You have to push the luxcloud source to the git directory. \n\n You may also use luxcloud import [dir] to populate images."
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

	# Import every tar file in IMPORTDIR to docker
	IMPORTDIR=$1

	for IMAGE in $IMPORTDIR/*.tar
	do
		docker load -i $IMPORTDIR/$IMAGE
	done
	
	# Check how much is now used
	spaceused 2

	# Next is step 2
	writestep 2
}

get(){
	# Check that we should do this now
	checkstep 1

	# Import every image in $IMAGES from specified registry
	REGISTRY=$1
	IMAGES="$2"

	for IMAGE in $IMPORTDIR/*.tar
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

edit(){
	nano $CONFIG
}


#####################################################                                            ###############################################
#####################################################                 HELPERS                    ###############################################
#####################################################                                            ###############################################


spaceused(){
	spaceused=$(df | grep root | awk '{print $3}')
	echo -e "SPACE_USED_$1='$spaceused' \n" >> $CONFIG
}

checkstep(){
	if [[ "$NEXT_STEP" = 3 ]]
	then
		echo "You are done!"
		exit 1
	elif [[ "$NEXT_STEP" != "$1" ]]
	then
		echo "You have to run the scripts in right order. Check usage for more info."
		exit 1
	fi
}

writestep(){
	if [ -z "$NEXT_STEP" ]
	then
		#NEXT_STEP is unset, write to file
		echo -e "NEXT_STEP=$1 \n" >> $CONFIG
	else
		# Read current step and write the new one
		sed -e "s@NEXT_STEP=$NEXT_STEP@NEXT_STEP=$1@" -i $CONFIG
	fi
}

#####################################################                                            ###############################################
#####################################################                 WHAT TO START				 ###############################################
#####################################################                                            ###############################################

case $1 in
	'install')
		install;;
	'build')
		build $2;;
	'import')
		import $2;;
	'setup')
		setup;;
	'status')
		status;;
	'edit')
		edit;;
	*)
		usage;;
esac