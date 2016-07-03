
IMAGE_NAME=kubernetesonarm/cross-compile-addons:0.8.0
ARCH?=arm
OUTPUT?=./bin/$(ARCH)

ifeq ($(ARCH),arm)
	CC=arm-linux-gnueabi-gcc
endif
ifeq ($(ARCH),arm64)
	CC=aarch64-linux-gnu-gcc
endif
ifeq ($(ARCH),ppc64le)
	CC=powerpc64le-linux-gnu-gcc
endif

build-image:
	docker build --build-arg CC=$(CC) --build-arg GOARCH=$(ARCH) -t $(IMAGE_NAME) .

cross-compile: build-image
	docker cp $(shell docker create $(IMAGE_NAME)):/build/bin $(OUTPUT)

# registry addon
build-registry: cross-compile
	cp -f $(OUTPUT)/registry ./registry/

# heapster addon
build-heapster: cross-compile
	cp -f $(OUTPUT)/heapster $(OUTPUT)/eventer ./heapster/

build-grafana: cross-compile
	curl -sSL https://raw.githubusercontent.com/kubernetes/heapster/${HEAPSTER_VERSION}/grafana/dashboards/cluster.json > ./grafana/cluster.json
	curl -sSL https://raw.githubusercontent.com/kubernetes/heapster/${HEAPSTER_VERSION}/grafana/dashboards/pods.json > ./grafana/pods.json
	cp -f $(OUTPUT)/grafana.tar ./grafana/

build-influxdb: cross-compile
	cp -f $(OUTPUT)/influxd $(OUTPUT)/influxdb.toml ./influxdb/

# loadbalancer addon
build-loadbalancer: cross-compile
	cp -f $(OUTPUT)/service_loadbalancer ./loadbalancer/

# scale-demo addon
build-scale-demo: cross-compile
	cp -f $(OUTPUT)/loader $(OUTPUT)/aggregator ./scale-demo/

build-registry: cross-compile
	cp -f $(OUTPUT)/registry ./registry/

build-heapster: cross-compile
	cp -f $(OUTPUT)/heapster $(OUTPUT)/eventer ./heapster/


# docker run --rm --privileged multiarch/qemu-user-static:register --reset
# curl -sSL --retry 5 https://github.com/multiarch/qemu-user-static/releases/download/v2.5.0/x86_64_qemu-${QEMUARCH}-static.tar.xz | tar -xJ -C ${TEMP_DIR}

