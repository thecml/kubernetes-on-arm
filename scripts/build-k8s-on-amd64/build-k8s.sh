#!/bin/bash

set -e

echo "OUTPUT=$OUTPUT"

# Build two compilation tools for host arch
GOARCH=amd64 go get github.com/tools/godep

# Build etcd
curl -sSL https://github.com/coreos/etcd/archive/$ETCD_VERSION.tar.gz | tar -C $ETCD_DIR -xz --strip-components=1 \
    && cd $ETCD_DIR \
    && ./build \
    && cp bin/* $OUT_DIR

# Build flannel
curl -sSL https://github.com/coreos/flannel/archive/$FLANNEL_VERSION.tar.gz | tar -C $FLANNEL_DIR -xz --strip-components=1 \
    && cd $FLANNEL_DIR  \
    && CGO_ENABLED=1 ./build \
    && cp bin/* $OUT_DIR

# Build kubernetes
curl -sSL https://github.com/kubernetes/kubernetes/archive/$K8S_VERSION.tar.gz | tar -C $K8S_DIR -xz --strip-components=1 \
    && cd $K8S_DIR \
    && CGO_ENABLED=1 ./hack/build-go.sh cmd/hyperkube cmd/kubectl \
    && cp $OUTPUT/* $OUT_DIR

cd $K8S_DIR/cluster/addons/dns/kube2sky \
    && make kube2sky \
    && cp kube2sky $OUT_DIR

CGO_ENABLED=0 go get -a -installsuffix cgo --ldflags '-w' github.com/skynetservices/skydns \
    && cp $GOPATH/bin/linux_$GOARCH/skydns $OUT_DIR
