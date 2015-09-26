#!/bin/bash
# Use this to config the luxcloud node
# Install the necessary packages


# Usage: 
# lux install
# lux (build|import|get)
# lux setup

# lux edit

# lux export

# lux stats
# lux usage
# lux upgrade?
# lux refresh?
# lux version?

LUXDIR="/var/lib/luxcloud"
SOURCEDIR="/lib/luxas/luxcloud"
CONFIG="$LUXDIR/config.sh"
source $CONFIG

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
  	exit 1
fi

# Error handler
trap 'exit' ERR

usage(){
	cat <<EOF
	Usage: 
	 1: lux install 
	 2: lux (build|import [archive])
	 3: lux setup 
	Then your done!

	Other commands:
		lux info - Displays important info about the computer and enviroinment
		lux prodstate - Benchmarks if it could be taken to production
		lux edit - Edits the config file via nano
		
EOF
}

install() {

	# If this file doesn't exist, install
	if [[ ! -f $LUXDIR/.installed ]]; then
		# Check how much space there is now
		spaceused 0

		# Install all packages
		time $LUXDIR/install.sh

		# And after
		spaceused 1

		# Make sure we can't directly install again
		touch $LUXDIR/.installed

		# Reboot for changes to take effect, IS REQUIRED FOR DOCKER TO FUNCTION
		echo "Rebooting..."
		reboot
	else
		echo -e "It seems like you have run this command before. You should run 'lux refresh' instead. \n To run 'lux install' again, simply 'rm $LUXDIR/.installed'"
		exit 1
	fi
}

build(){

	#If we have installed core packages
	if [[ -f $LUXDIR/.installed ]]; then

		# Check if the images directory is present, so we may build the images
		if [[ $# = 0 && -d "$SOURCEDIR/images" ]]; then

			# Only print usage
			$SOURCEDIR/images/build.sh

		elif [[ -d "$SOURCEDIR/images" ]]; then

			# Build them and record the time
			time $SOURCEDIR/images/build.sh "$@"

			# Check how much is now used
			spaceused 2
		else
			echo -e "You have to push the luxcloud source to the git directory. \n\n You may also use luxcloud import [dir] to populate images."
			exit 1
		fi
	else
		echo -e "It is recommended that you install the core packages via 'lux install' before running this command.\n If you know what you are doing, run: 'touch $LUXDIR/.installed', to proceed"
		exit 1
	fi
}

import(){

	# Import this tar file, with one or many images
	time docker load -i $1
	
	# Check how much is now used
	spaceused 2
}

setup(){

	# Setup kubernetes, (etcd) and flannel
	time $LUXDIR/k8s.sh

	# Check how much is now used
	spaceused 3
}

edit(){
	nano $CONFIG
}

info(){

	echo "Lux version on sd card build: $LUX_VERSION"
	LUX_VERSION=""

	if [[ -d $SOURCEDIR ]]; then
		source $SOURCEDIR/images/version.sh
		echo "Current luxcloud version in source: $LUX_VERSION"
	fi

	echo "Architecture: $(uname -m)" 

	echo "Processors:"
	cat /proc/cpuinfo | grep "model name"

	echo "RAM Memory: $(free -m | grep Mem | awk '{print $2}') MiB"
	echo "Free RAM Memory: $(free -m | grep Mem | awk '{print $3}') MiB"
	echo "Kernel: $(uname) $(uname -r | grep -o "[0-9.]*" | grep "[.]")"
	
	#pacman --version
	#systemctl --version
}
prodstate(){
	/var/lib/docker-bench/docker-bench-security.sh
}


#####################################################                                            ###############################################
#####################################################                 HELPERS                    ###############################################
#####################################################                                            ###############################################


spaceused(){
	spaceused=$(df | grep root | awk '{print $3}')
	echo -e "SPACE_USED_$1='$spaceused' \n" >> $CONFIG
}

#####################################################                                            ###############################################
#####################################################                 WHAT TO START				 ###############################################
#####################################################                                            ###############################################

ACTION=$1
shift

case $ACTION in
	'install')
		install;;
	'build')
		build "$@";;
	'import')
		import $1;;
	'setup')
		setup;;
	'status')
		status;;
	'edit')
		edit;;
	'info')
		info;;
	'prodstate')
		info;;
	*)
		usage;;
esac