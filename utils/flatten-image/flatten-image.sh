#!/bin/bash

# Arguments:
# $1: the old image name
# $2: the new image

# Example ./flatten-image.sh luxas/raspbian-build luxas/raspbian

# This neat trick will apply things like removal of unused files. Use carefully.
# https://labs.ctl.io/optimizing-docker-images/?hvid=4wO7Yt

# Run a container, for making a filesystem
CID=$(docker run -d $1)

# Export that filesystem and import it as an image
docker export $CID | docker import - $2

# Remove the temporary container
docker rm $CID