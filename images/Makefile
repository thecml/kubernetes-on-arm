.PHONY: alpine archlinux go kubebuild nodejs kubweb all

all: build

build: build_luxas build_k8s

# This could be improved with docker in docker

build_luxas:
	# Base images
	#luxas/raspbian/build.sh
	#luxas/archlinux/build.sh
	#luxas/alpine/build.sh

	# Langauges
	#luxas/nodejs/build.sh
	luxas/go/build.sh

build_k8s:
	# Make binaries
	k8s/build/build.sh

	# Binary images
	k8s/etcd/build.sh
	k8s/flannel/build.sh
	k8s/pause/build.sh

	# Hyperkube
	k8s/hyperkube/build.sh

	# The web interface
	k8s/web/build.sh



# Clean up everything, all ps -a all luxas and k8s images
clean:
	echo "Not Implemented"