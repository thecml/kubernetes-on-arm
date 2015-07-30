FROM luxas/raspbian

# Install hyperkube
RUN apt-install iptables ca-certificates

# Copy files
COPY hyperkube /hyperkube
COPY master-multi.json /etc/kubernetes/manifests-multi/master.json
COPY safe_format_and_mount /usr/share/google/safe_format_and_mount

# Make them executable
RUN chmod a+rx /usr/share/google/safe_format_and_mount && \
	chmod a+rx /hyperkube
