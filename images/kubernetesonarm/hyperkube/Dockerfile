FROM luxas/raspbian

# Install required packages
RUN apt-install iptables \ 
				ca-certificates \
				file \
				util-linux \
				socat

# Copy files
COPY hyperkube /
COPY master-multi.json /etc/kubernetes/manifests-multi/master.json
COPY safe_format_and_mount /usr/share/google/safe_format_and_mount

# Do as upstream
RUN cp /usr/bin/nsenter /nsenter