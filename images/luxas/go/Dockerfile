FROM luxas/raspbian

# Install build tools
# Make directories
# Download and extract go
# And build
RUN apt-install curl git gcc build-essential && \
	mkdir /goroot /gopath && \
	curl -sSL https://golang.org/dl/go1.4.2.src.tar.gz | tar -xz -C /goroot --strip-components=1 && \
	cd /goroot/src && ./make.bash

ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin