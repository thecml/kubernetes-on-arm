#!/bin/bash

echo "Building Helm"

git clone https://github.com/kubernetes/helm.git $K8S_HELM
cd $K8S_HELM

GOARCH= GOBIN=$GOPATH/bin make bootstrap

echo "Building helm for ARM " $TARGET
cd $K8S_HELM/cmd/helm
go build -a -installsuffix cgo -ldflags '-w' -o helm
cp helm $OUT_DIR

echo "Building tiller for ARM " $TARGET
cd $K8S_HELM/cmd/tiller
go build -a -installsuffix cgo -ldflags '-w' -o tiller
cp tiller $OUT_DIR
