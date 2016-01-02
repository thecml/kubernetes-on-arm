#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/..

PACKAGE=${PACKAGE:-1}

# Move to an USB or a folder
if [[ $# == 1 ]]; then

    # But, first package binaries
    if [[ $PACKAGE == 1 ]]; then

		echo "Packaging artifacts..."
        scripts/package.sh
    fi

    source scripts/common.sh

    BUILDDIR=release/latest
    OUTDIR="$(parse-path-or-disc $1)/kubernetesonarm_$(date +%d%m%y_%H%M)"

    mkdir -p $OUTDIR

    echo "Copying files..."
    cp $BUILDDIR/* $OUTDIR

    cleanup-path-or-disc
else
	cat <<EOF
Packages Kubernetes images, binaries, the .deb file and kubectl to a target

Usage:
PACKAGE=(1=default|0) scripts/ship-package.sh [disc or partition or absolute path]

Examples:
PACKAGE=0 scripts/ship-package.sh /dev/sda2
PACKAGE=1 scripts/ship-package.sh /dev/sda [/dev/sda1 automatically chosen]
scripts/ship-package.sh /etc/k8s-artifacts

Other variables:
PACKAGE_BRANCH: The ref that git should checkout when building the package. Defaults to master
PACKAGE_REVISION: The revision of the package. Defaults to 1
EOF
fi