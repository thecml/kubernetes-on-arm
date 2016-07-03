
ARCH?=arm
IMAGE_NAME?=build-k8s-on-amd64
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


all: copy-binaries
build:
	docker build --build-arg CC=$(CC) --build-arg GOARCH=$(ARCH) -t $(IMAGE_NAME) .

copy-binaries: build
	@rm -rf $(OUTPUT)
	@mkdir -p $(shell dirname $(OUTPUT))

	docker cp $(shell docker create $(IMAGE_NAME)):/output $(OUTPUT)
