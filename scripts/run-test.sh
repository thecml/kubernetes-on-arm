#!/bin/bash

usage(){
	cat <<EOF
	Run a test...

	Tests just now:
	$(ls -l tests | awk '{print $9}')
EOF
}

cd "$( dirname "${BASH_SOURCE[0]}" )"

if [[ $# == 0 ]]; then
	usage
	exit
fi

mkdir -p logs
time tests/$1.sh 2>&1 > "logs/$(date +%d%m%y_%H%M)_$1.log" >/dev/stdout