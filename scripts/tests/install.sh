#!/bin/bash

# Output info before
kube-config info

# Install all packages and record the time
time TIMEZONE=Europe/Helsinki SWAP=1 NEW_HOSTNAME=kubemaster REBOOT=0 kube-config install

# Output info after, for comparison
kube-config info

# A reboot is needed
reboot