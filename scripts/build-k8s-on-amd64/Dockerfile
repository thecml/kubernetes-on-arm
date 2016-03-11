FROM golang:1.5.3

MAINTAINER Lucas Käldström <lucas.kaldstrom@hotmail.co.uk>

# Enable cgo cross-compilation for armel
RUN echo "deb http://emdebian.org/tools/debian/ jessie main" > /etc/apt/sources.list.d/crosstools.list \
    && curl -s http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add - \
    && dpkg --add-architecture armel \
    && apt-get update \
    && apt-get install -y build-essential crossbuild-essential-armel rsync upx

# Important ENV variables
ENV GOARM=6 \
    GOARCH=arm  \
    CC=arm-linux-gnueabi-gcc \
    K8S_DIR="$GOPATH/src/k8s.io/kubernetes" \
    K8S_CONTRIB="$GOPATH/src/k8s.io/contrib" \
    ETCD_DIR="$GOPATH/src/github.com/coreos/etcd" \
    FLANNEL_DIR="$GOPATH/src/github.com/coreos/flannel" \
    REGISTRY_DIR="$GOPATH/src/github.com/docker/distribution" \
    OUT_DIR="/output" \
    ETCD_VERSION=v2.2.5 \
    FLANNEL_VERSION=v0.5.5 \
    K8S_VERSION=v1.1.7 \
    REGISTRY_VERSION=v2.3.0 \
    KUBE_STATIC_OVERRIDES="kubectl" \
    KUBE_BUILD_PLATFORMS=linux/arm                              


# Make directories
RUN mkdir -p $OUT_DIR \
            $K8S_DIR \
            $K8S_CONTRIB \
            $GOPATH/src/github.com/GoogleCloudPlatform \
            $ETCD_DIR \
            $FLANNEL_DIR \
            $REGISTRY_DIR \
    && ln -s $GOPATH/src/k8s.io/kubernetes $GOPATH/src/github.com/GoogleCloudPlatform/kubernetes

# Build etcd
RUN curl -sSL https://github.com/coreos/etcd/archive/$ETCD_VERSION.tar.gz | tar -C $ETCD_DIR -xz --strip-components=1 \
    && cd $ETCD_DIR \
    && ./build \
    && cp bin/* $OUT_DIR

# Build flannel
RUN curl -sSL https://github.com/coreos/flannel/archive/$FLANNEL_VERSION.tar.gz | tar -C $FLANNEL_DIR -xz --strip-components=1 \
    && cd $FLANNEL_DIR  \
    && CGO_ENABLED=1 ./build \
    && cp bin/* $OUT_DIR

# Build kubernetes
RUN curl -sSL https://github.com/kubernetes/kubernetes/archive/$K8S_VERSION.tar.gz | tar -C $K8S_DIR -xz --strip-components=1 \
    && cd $K8S_DIR \
    && mv Godeps/_workspace/src/github.com/docker/libcontainer/seccomp/jump_amd64.go \
          Godeps/_workspace/src/github.com/docker/libcontainer/seccomp/jump.go \
    && sed -e "s@,amd64@@" -i Godeps/_workspace/src/github.com/docker/libcontainer/seccomp/jump.go \
    && curl -sSL https://raw.githubusercontent.com/kubernetes/kubernetes/8c1d820435670e410f8fd54401906c3d387c2098/pkg/util/io/writer.go > pkg/util/io/writer.go \
    && CGO_ENABLED=1 ./hack/build-go.sh cmd/hyperkube cmd/kubectl \
    && cp _output/local/bin/linux/arm/* $OUT_DIR

# Build two compilation tools for host arch
RUN GOARCH=amd64 go get github.com/tools/godep \
    && GOARCH=amd64 go get github.com/pwaller/goupx

# Build the pause image
RUN cd $K8S_DIR/build/pause \
    && CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags '-w' ./pause.go \
    && goupx pause \
    && cp pause $OUT_DIR

RUN cd $K8S_DIR/cluster/addons/dns/kube2sky \
    && sed -e "s@GOARCH=amd64@GOARCH=arm@" -i Makefile \
    && make kube2sky \
    && cp kube2sky $OUT_DIR

RUN CGO_ENABLED=0 go get -a -installsuffix cgo --ldflags '-w' github.com/skynetservices/skydns \
    && cp $GOPATH/bin/linux_arm/skydns $OUT_DIR

# Build Kubernetes contrib binaries
RUN curl -sSL https://github.com/kubernetes/contrib/archive/master.tar.gz | tar -xz -C $K8S_CONTRIB --strip-components=1 \
    && cd $K8S_CONTRIB/service-loadbalancer \
    && make server \
    && cp service_loadbalancer $OUT_DIR

RUN cd $K8S_CONTRIB/exec-healthz \
    && make server \
    && cp exechealthz $OUT_DIR

RUN cd $K8S_CONTRIB/scale-demo/aggregator \
    && make aggregator \
    && cp aggregator $OUT_DIR

RUN cd $K8S_CONTRIB/scale-demo/vegeta \
    && CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags '-w' -o loader \
    && cp loader $OUT_DIR

# Build docker registry for the addons
RUN curl -sSL https://github.com/docker/distribution/archive/$REGISTRY_VERSION.tar.gz | tar -xz -C $REGISTRY_DIR --strip-components=1 \
    && cd $REGISTRY_DIR/cmd/registry \
    && CGO_ENABLED=1 GOPATH=$REGISTRY_DIR/Godeps/_workspace:$GOPATH go build \
    && cp registry $OUT_DIR

#RUN CC=arm-linux-gnueabi-gcc GOARM=6 CGO_ENABLED=1 GOARCH=arm KUBE_BUILD_PLATFORMS=linux/arm hack/build-go.sh cmd/hyperkube