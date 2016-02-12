FROM luxas/raspbian

# Install packages and download the repo
RUN apt-install git fakeroot ca-certificates \
	&& git clone https://github.com/luxas/kubernetes-on-arm

# Copy the script and the control file
COPY makedeb.sh debian-control-file /

# Always run this script
ENTRYPOINT ["/makedeb.sh"]