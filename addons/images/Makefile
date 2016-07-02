
CC_IMAGE_NAME=kubernetesonarm/cross-compile-addons:0.8.0

build-image:
	docker build -t $(CC_IMAGE_NAME) .

cross-compile: build-image
	docker cp $(shell docker create $(CC_IMAGE_NAME)):/build/bin ./bin

build-grafana: cross-compile
	curl -sSL https://raw.githubusercontent.com/kubernetes/heapster/${HEAPSTER_VERSION}/grafana/dashboards/cluster.json > ./grafana/cluster.json
	curl -sSL https://raw.githubusercontent.com/kubernetes/heapster/${HEAPSTER_VERSION}/grafana/dashboards/pods.json > ./grafana/pods.json
	cp -f ./bin/gosu ./bin/grafana.tar ./grafana/

build-influxdb: cross-compile
	cp -f ./bin/influxd ./bin/influxdb.toml ./influxdb/

build-registry: cross-compile
	cp -f ./bin/registry ./registry/

build-heapster: cross-compile
	cp -f ./bin/heapster ./bin/eventer ./heapster/


# docker run --rm --privileged multiarch/qemu-user-static:register --reset
# curl -sSL --retry 5 https://github.com/multiarch/qemu-user-static/releases/download/v2.5.0/x86_64_qemu-${QEMUARCH}-static.tar.xz | tar -xJ -C ${TEMP_DIR}

