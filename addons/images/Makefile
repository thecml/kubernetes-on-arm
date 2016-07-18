include ../../version
IMAGE_NAME=kubernetesonarm/cross-compile-addons:$(VERSION)
ARCH?=arm
OUTPUT?=./bin/$(ARCH)
SUPPORTED_ADDONS = grafana heapster influxdb loadbalancer registry scale-demo scale-nginx tiller

ifeq ($(ARCH),arm)
	CC=arm-linux-gnueabi-gcc
endif
ifeq ($(ARCH),arm64)
	CC=aarch64-linux-gnu-gcc
endif
ifeq ($(ARCH),ppc64le)
	CC=powerpc64le-linux-gnu-gcc
endif

all: build
build: $(addprefix build-,$(SUPPORTED_ADDONS))
build-%: prepare-%
	docker build -t kubernetesonarm/$*:$(VERSION) $*

push: $(addprefix push-,$(SUPPORTED_ADDONS))
push-%: build-%
	docker push kubernetesonarm/$*:$(VERSION)

build-image:
	docker build --build-arg CC=$(CC) --build-arg GOARCH=$(ARCH) -t $(IMAGE_NAME) .

cross-compile: build-image
	rm -rf $(OUTPUT)
	mkdir -p $(OUTPUT)
	docker cp $(shell docker create $(IMAGE_NAME)):/build/bin $(OUTPUT)

add-qemu:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	curl -sSL --retry 5 https://github.com/multiarch/qemu-user-static/releases/download/v2.5.0/x86_64_qemu-$(ARCH)-static.tar.xz | tar -xJ -C $(OUTPUT)

# registry addon
prepare-registry: cross-compile
	cp -f $(OUTPUT)/registry ./registry/

# heapster addon
prepare-heapster: cross-compile
	cp -f $(OUTPUT)/heapster $(OUTPUT)/eventer ./heapster/

prepare-grafana: cross-compile
	curl -sSL https://raw.githubusercontent.com/kubernetes/heapster/master/grafana/dashboards/cluster.json > ./grafana/cluster.json
	curl -sSL https://raw.githubusercontent.com/kubernetes/heapster/master/grafana/dashboards/pods.json > ./grafana/pods.json
	cp -f $(OUTPUT)/grafana.tar $(OUTPUT)/gosu ./grafana/

prepare-influxdb: cross-compile
	cp -f $(OUTPUT)/influxd $(OUTPUT)/influxdb.toml ./influxdb/

# loadbalancer addon
prepare-loadbalancer: cross-compile add-qemu
	cp -f $(OUTPUT)/service_loadbalancer $(OUTPUT)/qemu-$(ARCH)-static ./loadbalancer/

# scale-demo addon
prepare-scale-demo: cross-compile
	cp -f $(OUTPUT)/loader $(OUTPUT)/aggregator ./scale-demo/

prepare-scale-nginx: add-qemu
	cp -f $(OUTPUT)/qemu-$(ARCH)-static ./scale-nginx/

# helm addon
prepare-tiller: cross-compile
	cp -f $(OUTPUT)/tiller ./tiller/
