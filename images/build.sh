#!/bin/bash
# How this build works
# This is a replacement for the Makefile

usage(){
cat <<EOF
This will build all our ARM docker images in this directory.

Usage:

./build.sh all (in no specific order)
./build.sh [some prefix] (e.g. luxas, will build all images under ./luxas/)
./build.sh [image] [image]... (e. g. luxas/archlinux k8s/build. Images will build from left to right)
EOF
}


