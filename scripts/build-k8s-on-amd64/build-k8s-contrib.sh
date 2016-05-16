#!/bin/bash

# Build Kubernetes contrib binaries
curl -sSL https://github.com/kubernetes/contrib/archive/master.tar.gz | tar -xz -C $K8S_CONTRIB --strip-components=1 \
    && cd $K8S_CONTRIB/service-loadbalancer \
    && make server \
    && cp service_loadbalancer $OUT_DIR

cd $K8S_CONTRIB/exec-healthz \
    && TAG=1.0 ARCH=$GOARCH make server \
    && cp exechealthz $OUT_DIR

cd $K8S_CONTRIB/scale-demo/aggregator \
    && make aggregator \
    && cp aggregator $OUT_DIR

cd $K8S_CONTRIB/scale-demo/vegeta \
    && CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags '-w' -o loader \
    && cp loader $OUT_DIR

cd $K8S_CONTRIB/ingress/controllers/nginx \
    && CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags "-w -X main.version=${INGRESS_CONTROLLER_VERSION} -X main.gitRepo=${CONTRIB_REPO}" -o nginx-ingress-controller \
    && cp nginx-ingress-controller $OUT_DIR

cd $K8S_CONTRIB/404-server \
    && CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags '-w' -o 404-server ./server.go \
    && cp 404-server $OUT_DIR

# Build docker registry for the addons
curl -sSL https://github.com/docker/distribution/archive/$REGISTRY_VERSION.tar.gz | tar -xz -C $REGISTRY_DIR --strip-components=1 \
    && cd $REGISTRY_DIR/cmd/registry \
    && CGO_ENABLED=0 GOPATH=$REGISTRY_DIR/Godeps/_workspace:$GOPATH go build -a --installsuffix cgo \
    && cp registry $OUT_DIR
