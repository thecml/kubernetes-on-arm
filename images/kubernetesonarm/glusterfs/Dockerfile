FROM resin/rpi-raspbian:jessie

RUN apt-get update && apt-get install -y -q \
        xfsprogs \
        glusterfs-server \
        glusterfs-client \
        && rm -rf /var/cache/apt/* /var/lib/apt/lists/*
