FROM luxas/raspbian

# Install required packages
RUN apt-install iptables \ 
				ca-certificates \
				file \
				util-linux \
				socat \
				curl \
				ethtool

# Copy files
COPY hyperkube \
	setup-files.sh \		
	make-ca-cert.sh \
	
	# Copy to rootfs
	/

COPY master-multi.json /etc/kubernetes/manifests-multi/master.json
COPY safe_format_and_mount /usr/share/google/safe_format_and_mount

# Do as upstream
RUN cp /usr/bin/nsenter /nsenter