FROM luxas/raspbian

# Install hyperkube
RUN apt-install iptables ca-certificates

# Copy files
COPY hyperkube /
COPY master-multi.json /etc/kubernetes/manifests-multi/master.json

# Do as upstream
RUN cp /usr/bin/nsenter /nsenter


# Make it executable, necessary?
#RUN	chmod a+rx /hyperkube
