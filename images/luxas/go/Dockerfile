FROM luxas/raspbian

# Copy files
COPY version.sh inbuild.sh /

# Make goroot and gopath variables
ENV GOROOT=/goroot GOPATH=/gopath

# Hard-code the $PATH
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$GOROOT/bin:$GOPATH/bin

# Make executable and run inbuild
RUN chmod +x /version.sh /inbuild.sh && \
	/inbuild.sh