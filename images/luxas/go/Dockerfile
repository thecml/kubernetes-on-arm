FROM luxas/raspbian

# Copy version info
COPY version.sh /

# Make goroot and gopath variables
ENV GOROOT=/goroot \
	GOPATH=/gopath \
	PATH=$PATH:/goroot/bin:/gopath/bin \
	GOARM=6

# Install software in one layer
RUN chmod +x /version.sh \
    && mkdir /goroot1.4 /goroot /gopath \
    && apt-install --no-install-recommends	\
        # Download software (securely)
        curl 													\
        ca-certificates 										\
        rsync													\

        # Version control
        git 													\
        mercurial												\
		
        # Build tools
        gcc 													\
        g++ 													\
        make 													\
        patch 													\
        libc6-dev 												\

        # Executable packer
        upx

# Much, much faster to just download instead of compiling from source
RUN . /version.sh \
    && curl -sSL "https://github.com/hypriot/golang-armbuilds/releases/download/v${GO_VERSION}/go${GO_VERSION}.linux-armv6.tar.gz" | tar -xzC /usr/local


# Build go1.4.x in the other layer, run this if GO_BOOTSTRAP_VERSION is set
#RUN . /version.sh \
#	&& if [ ! -z $GO_BOOTSTRAP_VERSION ]; then \
#
#	# Download source code
#	curl -sSL https://golang.org/dl/$GO_BOOTSTRAP_VERSION.src.tar.gz | tar -xz -C /goroot1.4 --strip-components=1 \
#
#	# Build go
#	&& cd /goroot1.4/src && ./make.bash; fi

# Build the "real" go version
#RUN . /version.sh \
#	# Download source code
#	&& curl -sSL https://golang.org/dl/$GO_VERSION.src.tar.gz | tar -xz -C /goroot --strip-components=1 \
#
#	# Build go
#	&& cd /goroot/src && GOROOT_BOOTSTRAP=/goroot1.4 ./make.bash \
#
#	# Install godep, which is required in many projects
#	&& go get github.com/tools/godep 


# 													HACK													#
# Instead of:
# cd /goroot1.4/src && ./make.bash
#
# One may do this:
# cd /goroot1.4/src && ./make.bash --dist-tool						&& \
# /goroot1.4/pkg/tool/linux_arm/dist bootstrap -v 					&& \
# cp /goroot1.4/pkg/tool/linux_arm/go_bootstrap /goroot1.4/bin/go
#
# This will not build the whole go1.4, but instead build cmd/dist and the go_bootstrap tool, which is renamed to go
# Not sure if reliable, but it compiles
#