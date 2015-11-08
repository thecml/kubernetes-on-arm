#!/bin/bash

usage(){
	cat <<EOF
Run a test...

Tests just now:
$(ls -l tests | awk '{print $9}' | grep -o "[^.]*" | grep -v "sh")
EOF
}

cd /etc/kubernetes/source/scripts

if [[ $# == 0 ]]; then
	usage
	exit
fi

mkdir -p logs
time tests/$1.sh 2>&1 | tee "logs/$(date +%d%m%y_%H%M)_$1.log"