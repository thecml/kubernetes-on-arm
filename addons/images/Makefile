include ../../version
IMAGE_PREFIX=kubernetesonarm
IMAGE_NAME=$(IMAGE_PREFIX)/cross-compile-addons:$(VERSION)
ARCH?=arm
OUTPUT?=./bin/$(ARCH)
BUILD_DIR?=./bin/build/$(ARCH)
SUPPORTED_ADDONS = grafana heapster influxdb loadbalancer registry scale-demo scale-nginx tiller
CURDIR=$(shell pwd)

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

cross-compile-container:
	docker build --build-arg CC=$(CC) --build-arg GOARCH=$(ARCH) -t $(IMAGE_NAME) .

prepare-build: cross-compile-container
	rm -rf $(OUTPUT) $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	docker cp $(shell docker create $(IMAGE_NAME)):/build/bin $(OUTPUT)
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	curl -sSL --retry 5 https://github.com/multiarch/qemu-user-static/releases/download/v2.5.0/x86_64_qemu-$(ARCH)-static.tar.xz | tar -xJ -C $(OUTPUT)
	cp $(OUTPUT)/* $(BUILD_DIR)

build: $(addprefix build-,$(SUPPORTED_ADDONS))
build-%: prepare-build
	cp -f $*/* $(BUILD_DIR)
	docker build -t $(IMAGE_PREFIX)/$*:$(VERSION) $(BUILD_DIR)

push: $(addprefix push-,$(SUPPORTED_ADDONS))
push-%: build
	docker push $(IMAGE_PREFIX)/$*:$(VERSION)

clean:
	rm -rf bin
