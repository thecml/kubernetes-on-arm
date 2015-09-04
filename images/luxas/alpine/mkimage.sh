#!/bin/sh

# Original `mkimage-alpine.sh` by Eivind Uggedal (uggedal)
# Tailored for running inside a Docker container

# Code licensed under ISC license. Please see LICENSE file on this directory.

[ $(id -u) -eq 0 ] || {
  printf >&2 '%s requires root\n' "$0"
  exit 1
}

usage() {
  printf >&2 '%s: [-r release] [-m mirror]\n' "$0"
  exit 1
}

tmp() {
  TMP=$(mktemp -d /tmp/alpine-docker-XXXXXXXXXX)
  ROOTFS=$(mktemp -d /tmp/alpine-docker-rootfs-XXXXXXXXXX)
  trap "rm -rf $TMP $ROOTFS" EXIT TERM INT
}

apkv() {
  set -x
  curl -s $REPO/$ARCH/APKINDEX.tar.gz | tar -Oxz |
    grep '^P:apk-tools-static$' -a -A1 | tail -n1 | cut -d: -f2
}

getapk() {
  curl -s $REPO/$ARCH/apk-tools-static-$(apkv).apk |
    tar -xz -C $TMP sbin/apk.static
}

mkbase() {
  $TMP/sbin/apk.static --repository $REPO --update-cache --allow-untrusted \
    --root $ROOTFS --initdb add alpine-base
}

confrepo() {
  printf '%s\n' $REPO > $ROOTFS/etc/apk/repositories
}

save() {
  tar --numeric-owner -C $ROOTFS -c . | xz > /tmp/rootfs.tar.xz
  rm -rf $TMP $ROOTFS
}

while getopts "hm" opt; do
  case $opt in
    m)
      MIRROR=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

REL=edge
MIRROR=${MIRROR:-http://nl.alpinelinux.org/alpine}
REPO=$MIRROR/$REL/main

# Set architecture, with many possible 'uname -m' outputs, especially important on the ARM platform
case "$(uname -m)" in
  x86_64*)
    ARCH=x86_64;;
  i?86_64*)
    ARCH=x86_64;;
  amd64*)
    ARCH=x86_64;;
  arm*)
    ARCH=armhf;;
  i?86*)
    ARCH=x86;;
  *)
    echo "Unsupported host arch. Must be 32-bit, 64-bit or ARM."
    exit 1
    ;;
esac

tmp && getapk && mkbase && confrepo && save
