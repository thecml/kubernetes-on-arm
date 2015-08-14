.PHONY: all build build_luxas build_k8s

all: build clean

build: build_luxas build_k8s


# include $HELPER could be used
HELPER=../utils/docker-utils.sh

# This could be improved with docker in docker
build_luxas:
	# Base images
	$HELPER "build" "luxas" "raspbian archlinux alpine nodejs nginx go dockviz"

build_k8s:
	$HELPER "build" "k8s" "build etcd flannel hyperkube pause web"

export_all:
	mkdir -p archive archive/$(date +%d%m%y)
	$HELPER "export" "luxas" "archive/$(date +%d%m%y)"
	$HELPER "export" "k8s" "archive/$(date +%d%m%y)"


# Clean up everything, all ps -a all luxas and k8s images
clean:
	docker rm $(docker ps -aq)

	# foreach here
	./luxas/raspbian/clean.sh
	./luxas/nodejs/clean.sh
	./luxas/alpine/clean.sh


