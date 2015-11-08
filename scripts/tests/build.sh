#!/bin/bash

kube-config info

time kube-config build-images

time kube-config build-addons

./package.sh