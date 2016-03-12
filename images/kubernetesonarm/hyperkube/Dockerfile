FROM resin/rpi-raspbian:jessie

# Install required packages
RUN apt-get update && apt-get install -y -q \
        iptables \
        ca-certificates \
        file \
        util-linux \
        socat \
        curl \
        ethtool \
        && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# Copy files
COPY hyperkube \
    setup-files.sh \
    make-ca-cert.sh \
    
    # Copy to rootfs
    /

COPY master.json /etc/kubernetes/manifests/master.json
COPY master-multi.json /etc/kubernetes/manifests-multi/master.json
COPY safe_format_and_mount /usr/share/google/safe_format_and_mount

# Since the official binary is built for armel, we need this symlink.
RUN ln -s /lib/ld-linux-armhf.so.3 /lib/ld-linux.so.3 \
    && chmod +x /hyperkube