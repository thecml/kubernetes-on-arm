FROM resin/rpi-raspbian:jessie

# Install software in one layer
RUN apt-get update && apt-get install -y -q --no-install-recommends \
        # Download software
        curl \
        ca-certificates \
        rsync \

        # Version control
        git \
        mercurial \
        
        # Build tools
        gcc \
        g++ \
        make \
        patch \
        libc6-dev \

        # Executable packer
        upx \
        && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# Copy version info
COPY version.sh /

# Make goroot and gopath variables
ENV GOROOT=/usr/local/go \
    GOROOT_BOOTSTRAP_PATH=/goroot1.4 \
    GOPATH=/go \
    GOARM=6

# Set the PATH based on GOROOT and GOPATH
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Much, much faster to just download instead of compiling from source
RUN chmod +x /version.sh \
    && . /version.sh \
    && mkdir -p $GOROOT $GOROOT_BOOTSTRAP_PATH $GOPATH \
    && curl -sSL https://storage.googleapis.com/golang/go${GO_VERSION}.linux-armv6l.tar.gz | tar -xzC $GOROOT --strip-components=1 \
    && go get github.com/tools/godep


# Build go1.4.x in the other layer, run this if GO_BOOTSTRAP_VERSION is set
#RUN . /version.sh \
#   && if [ ! -z $GO_BOOTSTRAP_VERSION ]; then \
#
#   # Download source code
#   curl -sSL https://golang.org/dl/go$GO_BOOTSTRAP_VERSION.src.tar.gz | tar -xz -C $GOROOT_BOOTSTRAP_PATH --strip-components=1 \
#
#   # Build go
#   && cd $GOROOT_BOOTSTRAP_PATH/src && ./make.bash; fi

# Build the "real" go version
#RUN . /version.sh \
#   # Download source code
#   && curl -sSL https://golang.org/dl/go$GO_VERSION.src.tar.gz | tar -xz -C $GOROOT --strip-components=1 \
#
#   # Build go
#   && cd $GOROOT/src && GOROOT_BOOTSTRAP=$GOROOT_BOOTSTRAP_PATH ./make.bash \
#
#   # Install godep, which is required in many projects
#   && go get github.com/tools/godep 
