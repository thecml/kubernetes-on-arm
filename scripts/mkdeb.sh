#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/..
source scripts/common.sh

# Require two args
if [[ $# < 2 ]]; then
    cat <<EOF
Create a .deb and .tar.gz file of https://github.com/luxas/kubernetes-on-arm

Usage:
scripts/mkdeb.sh [output dir] [git_ref] [revision]

Arguments:
output: May be a disc or partition or absolute path
git_ref: A commit, tag or branch in the repo. Usage in this script: git checkout $git_ref
revision: The package revision.

Examples:
scripts/mkdeb.sh /dev/sda master 1 [/dev/sda1 automatically chosen]
scripts/mkdeb.sh /dev/sda2 dev 2
scripts/mkdeb.sh /etc/debs v0.6.2 1
EOF
    exit
fi

# Build the image
docker build -t kubernetesonarm/package scripts/package

rm -rf build
mkdir -p build

docker run --rm -it -v $(pwd)/build:/build kubernetesonarm/package $2 $3

# Get the directory we should put the file in
OUTDIR=$(parse-path-or-disc $1)

# Copy the .deb and .tar.gz package to the output directory
mkdir -p $OUTDIR
cp build/* $OUTDIR

# And remove the intermediate directory and container
rm -rf build

# Lastly, clean up the directory
cleanup-path-or-disc
