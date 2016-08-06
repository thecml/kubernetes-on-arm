#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/..
source scripts/common.sh

# Require two args
if [[ $# < 2 ]]; then
    cat <<EOF
Create a .deb and .tar.gz file of https://github.com/luxas/kubernetes-on-arm

Usage:
scripts/mkdeb.sh [output] [git_ref] [revision]

Arguments:
output: May be a disc or partition or absolute path
git_ref: A commit, tag or branch in the repo. Usage in this script: git checkout $git_ref
revision: The package revision. Just a number like 2

Examples:
scripts/mkdeb.sh /dev/sda master 1 [/dev/sda1 automatically chosen]
scripts/mkdeb.sh /dev/sda2 dev 2
scripts/mkdeb.sh /etc/debs v0.6.2 1
EOF
    exit
fi

# Build the image
docker build -t kubernetesonarm/package scripts/package

# Run the container
CID=$(docker run -d kubernetesonarm/make-deb $2 $3)

# Wait for the package process
docker wait $CID

# Get the directory we should put the file in
OUTDIR=$(parse-path-or-disc $1)

# Copy out the whole folder that includes the .deb
docker cp $CID:/build .

# Copy the .deb and .tar.gz package to the output directory
mkdir -p $OUTDIR
cp build/* $OUTDIR

# And remove the intermediate directory and container
rm -r build
docker rm $CID

# Lastly, clean up the directory
cleanup-path-or-disc
