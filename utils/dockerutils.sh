#!/bin/bash
build_images()
{
	PREFIX=$1
	IMAGES=$2

	for IMAGE in $IMAGES
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
		NEWNAME=$(echo $IMAGE | sed 's@/@_@')

		echo "Saving $IMAGE"

		docker save $IMAGE > $OUTPUT/$NEWNAME.tar
	done
}
clean_build(){
	for PREFIX in $2
	do
		for IMAGE in $PREFIX/*
		do
			if [[ -f "./$PREFIX/$IMAGE/clean.sh" ]]
			then
				./$PREFIX/$IMAGE/clean.sh
			fi
		done
	done
}


if [[ "$1" == "export" ]]
then
	export_images $2 $3
elif [[ "$1" == "build" ]]
then
	build_images $2 $3
elif [[ "$1" == "clean" ]]
then
	clean_build $2
fi