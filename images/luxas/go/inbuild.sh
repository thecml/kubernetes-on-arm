#!/bin/bash

# Read go version
source /version.sh

# Install build tools
apt-install curl \
			git \
			upx \
			gcc \
			build-essential \
			mercurial

# Make directories
mkdir /goroot /gopath

# Download and extract go
curl -sSL https://golang.org/dl/go$GO_VERSION.src.tar.gz | tar -xz -C /goroot --strip-components=1

# And build
cd /goroot/src
./make.bash

# Install godep, often useful
go get github.com/tools/godep 