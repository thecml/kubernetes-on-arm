#!/bin/bash

declare -r RED="\033[0;31m"
declare -r GREEN="\033[0;32m"
declare -r YELLOW="\033[0;33m"

function echo_green {
  echo -e "${GREEN}$1"; tput sgr0
}

function echo_red {
  echo -e "${RED}$1"; tput sgr0
}

function echo_yellow {
  echo -e "${YELLOW}$1"; tput sgr0
}


if [[ ! -f $(which kubectl 2>&1) ]]; then
    echo_red "kubectl not in PATH"
    echo_red "Failing"
    exit
fi

if [[ -z $MASTER_IP ]]; then
    echo_red "Export MASTER_IP in your env"
    echo_red "Failing"
    exit
fi

kube-config info

time kube-config enable-worker $MASTER_IP

export KUBERNETES_MASTER=http://$MASTER_IP:8080

WORKER_SECS=0
while [[ $(kubectl get no | grep $(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)) != "Ready" ]]; do sleep 1; ((WORKER_SECS++)); done

echo_yellow "Seconds before this worker came up: $WORKER_SECS"


docker ps

kube-config info
