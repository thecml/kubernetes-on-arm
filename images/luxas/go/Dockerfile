FROM luxas/raspbian

COPY version.sh /

# Install build tools
# Read go version
# Make directories
# Download and extract go
# And build
RUN ["/bin/bash", "-c", "source /version.sh"]

RUN apt-install \
	curl \
	git \
	upx \
	gcc \
	build-essential && \
	mkdir /goroot /gopath && \
	if [ -z "$GO_VERSION" ]; then GO_VERSION=1.4.2; fi && \
	curl -sSL https://golang.org/dl/go$GO_VERSION.src.tar.gz | tar -xz -C /goroot --strip-components=1 && \
	cd /goroot/src && ./make.bash

ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin