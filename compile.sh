#!/bin/bash

# This script is going to set up lucas amazing Raspberry Pi cloud service!
# This round is the Kubernetes round.
# We'll set up kubernetes common parts (used for both master and minion)
#
#
# Content:
# - build tools
# - go
#   - change path
# - etcd
# - flannel
# - kubernetes
#   - pause image
# - build base images

# Catch errors
trap 'exit' ERR


echo "Again, check how much free space we have on our system, for later comparision"
df -h

# Now we are in the current dir
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Make our archlinux image
./images/archlinux/build.sh

# NEW: luxas/archlinux

# Now we have that arch image
# Lets build our go image
./images/go/build.sh

# NEW: luxas/go




mkdir /var/lib/etcd