#!/bin/bash

kube-config info

cd /etc/kubernetes/source

BUILD=1 PACKAGE=1 scripts/ship-package.sh $(pwd)/$(cat version)