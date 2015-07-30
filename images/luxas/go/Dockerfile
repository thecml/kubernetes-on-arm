FROM luxas/raspbian

COPY version.sh /

# Install build tools
# Read go version
# Make directories
# Download and extract go
# And build
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN source /version.sh && \
	apt-install curl \
	git \
	upx \
	gcc \
	build-essential && \
	mkdir /goroot /gopath && \
	curl -sSL https://golang.org/dl/go$GO_VERSION.src.tar.gz | tar -xz -C /goroot --strip-components=1 && \
	cd /goroot/src && ./make.bash

#	if [ -z "$GO_VERSION" ]; then GO_VERSION=1.4.1; fi && \

ENV GOROOT=/goroot GOPATH=/gopath
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin