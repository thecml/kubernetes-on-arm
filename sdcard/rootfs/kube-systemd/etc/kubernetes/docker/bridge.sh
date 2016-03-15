#!/bin/sh

BRIDGE=$1
ACTION=$2
BRIDGE_CIDR=$3

case "$ACTION" in
  create)
    brctl addbr $BRIDGE
    ip addr add $BRIDGE_CIDR dev $BRIDGE
    ip link set dev $BRIDGE up
    ;;
  destroy)
    ip link set dev $BRIDGE down
    brctl delbr $BRIDGE
    ;;
esac
