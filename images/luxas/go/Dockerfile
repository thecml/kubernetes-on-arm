FROM luxas/raspbian

# Copy files
COPY version.sh inbuild.sh /

# Make goroot and gopath variables
# Hard-code the $PATH
ENV GOROOT=/goroot GOPATH=/gopath PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/goroot/bin:/gopath/bin

# Make executable and run inbuild
RUN chmod +x /version.sh /inbuild.sh && \
	/inbuild.sh