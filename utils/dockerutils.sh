#!/bin/bash
build_images()
{
	PREFIX=$1

	for IMAGE in ./$PREFIX/*
	do
	        if [[ -z $(docker images | grep "$PREFIX/$IMAGE") ]]
	        then
	                ./$PREFIX/$IMAGE/build.sh
	        else
	                echo "Already installed: $PREFIX/$IMAGE"
	        fi
	done
}


export_images()
{
	PREFIX=$1
	OUTPUT=$2

	for IMAGE in $(docker images | grep $PREFIX | awk '{print $1}')
	do
		docker save $IMAGE > $OUTPUT/$IMAGE.tar.gz
	done
}



if [[ "$1" == "export"]]
then
	export_images $2 $3
elif [[ "$1" == "build" ]]
	build_images $2
fi