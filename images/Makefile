.PHONY: all build build_luxas build_k8s

all: build clean

build: build_luxas build_k8s


# include $HELPER could be used
HELPER="../utils/dockerutils.sh"
DEPSCRIPT="./dependencies.sh"
DATE=$(shell date +%d%m%y)
IMAGE=""


install:
	${DEPSCRIPT} "$IMAGE"

# This could be improved with docker in docker
build_luxas:
	# Base images, the order is important
	${HELPER} "build" "luxas" "raspbian archlinux alpine nodejs nginx go dockviz"

build_k8s:
	# k8s images, the order here is also important
	${HELPER} "build" "k8s" "build etcd flannel hyperkube pause web"

export_all:
	# Make a directory with today's date
	mkdir -p archive archive/${DATE}

	# Export luxas and k8s images to tar files
	${HELPER} "export" "luxas" "archive/${DATE}"
	${HELPER} "export" "k8s" "archive/${DATE}"


# Clean up everything, all ps -a all luxas and k8s images
clean:
	docker rm $(docker ps -aq)
	${HELPER} "clean" "luxas k8s"