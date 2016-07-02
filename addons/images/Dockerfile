FROM gcr.io/google_containers/kube-cross:v1.6.2-1

ENV GOARCH=arm \
	GOARM=6 \
	CGO_ENABLED=0 \
	CC=arm-linux-gnueabi-gcc \
	OUTPUT_DIR=/build/bin \
	HEAPSTER_DIR=${GOPATH}/src/k8s.io/heapster \
	CONTRIB_DIR=${GOPATH}/src/k8s.io/contrib \
	REGISTRY_DIR=${GOPATH}/src/github.com/docker/distribution \
	INFLUXDB_DIR=${GOPATH}/src/github.com/influxdb/influxdb \
	GRAFANA_DIR=${GOPATH}/src/github.com/grafana/grafana

ENV HEAPSTER_VERSION=v1.1.0 \
	INFLUXDB_VERSION=v0.13.0 \
	GRAFANA_VERSION=v3.0.4 \
	GRAFANA_DL_VERSION=3.0.4-1464167696 \
	REGISTRY_VERSION=v2.5.0-rc.1 \
	GOSU_VERSION=1.9 \
	INGRESS_CONTROLLER_VERSION=0.8

RUN mkdir -p \
	${OUTPUT_DIR} \
	${HEAPSTER_DIR} \
	${CONTRIB_DIR} \
	${REGISTRY_DIR} \
	${INFLUXDB_DIR} \
	${GRAFANA_DIR}

RUN curl -sSL https://github.com/kubernetes/heapster/archive/${HEAPSTER_VERSION}.tar.gz | tar -C ${HEAPSTER_DIR} -xz --strip-components=1 \
	&& cd ${HEAPSTER_DIR} \
	&& go build -a --installsuffix cgo -o heapster k8s.io/heapster/metrics \
	&& go build -a --installsuffix cgo -o eventer k8s.io/heapster/events \
	&& cp heapster eventer ${OUTPUT_DIR}

RUN curl -sSL https://github.com/docker/distribution/archive/${REGISTRY_VERSION}.tar.gz | tar -xz -C ${REGISTRY_DIR} --strip-components=1 \
	&& cd ${REGISTRY_DIR} \
	&& go build -a --installsuffix cgo --ldflags "-X `go list ./version`.Version=${REGISTRY_VERSION}" -o bin/registry ./cmd/registry \
	&& cp bin/registry ${OUTPUT_DIR}

RUN curl -sSL https://github.com/influxdata/influxdb/archive/${INFLUXDB_VERSION}.tar.gz | tar -C ${INFLUXDB_DIR} -xz --strip-components=1 \
	&& cd ${INFLUXDB_DIR} \
	&& GOARCH=amd64 go get github.com/sparrc/gdm \
	&& gdm restore \
	&& ln -s $GOPATH/src/github.com/influxdb/influxdb $GOPATH/src/github.com/influxdata/ \
	&& go build -a --installsuffix cgo --ldflags="-s" -o influxd ./cmd/influxd \
	&& cp influxd ${OUTPUT_DIR} \
	&& GOARCH=amd64 go build -a --installsuffix cgo --ldflags="-s" -o influxd ./cmd/influxd \
	&& ./influxd config > ${OUTPUT_DIR}/influxdb.toml \
	&& sed -i 's/dir = "\/.*influxdb/dir = "\/data/' ${OUTPUT_DIR}/influxdb.toml

RUN curl -sSL https://github.com/grafana/grafana/archive/${GRAFANA_VERSION}.tar.gz | tar -C ${GRAFANA_DIR} -xz --strip-components=1 \
	&& cd ${GRAFANA_DIR} \
	&& GOARCH=amd64 CGO_ENABLED=1 CC=gcc go run build.go setup \
	&& godep restore \
	&& CGO_ENABLED=1 go build --ldflags="-w -X main.version=${GRAFANA_VERSION} -X main.commit=unknown-dev -X main.timestamp=0 -extldflags '-static'" -o grafana-server ./pkg/cmd/grafana-server \
	&& CGO_ENABLED=1 go build --ldflags="-w -X main.version=${GRAFANA_VERSION} -X main.commit=unknown-dev -X main.timestamp=0 -extldflags '-static'" -o grafana-cli ./pkg/cmd/grafana-cli \
	&& cp grafana-server grafana-cli ${OUTPUT_DIR}

RUN curl -sSL https://grafanarel.s3.amazonaws.com/builds/grafana_${GRAFANA_DL_VERSION}_amd64.deb > /tmp/grafana.deb \
	&& dpkg -x /tmp/grafana.deb /tmp/grafana \
	&& cp -f ${GRAFANA_DIR}/grafana-server ${GRAFANA_DIR}/grafana-cli /tmp/grafana/usr/sbin/ \
	&& cd /tmp/grafana && tar -cf ${OUTPUT_DIR}/grafana.tar . \
	&& curl -sSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-armel > ${OUTPUT_DIR}/gosu \
	&& chmod +x ${OUTPUT_DIR}/gosu

RUN curl -sSL https://github.com/kubernetes/contrib/archive/master.tar.gz | tar -xz -C ${CONTRIB_DIR} --strip-components=1 \
	&& cd ${CONTRIB_DIR}/service-loadbalancer \
	&& godep go build -a --installsuffix cgo -ldflags '-w' -o service_loadbalancer ./service_loadbalancer.go ./loadbalancer_log.go \
	&& cp service_loadbalancer ${OUTPUT_DIR} \
	&& cd ${CONTRIB_DIR}/scale-demo/aggregator \
    && make aggregator \
    && cp aggregator ${OUTPUT_DIR} \
	&& cd ${CONTRIB_DIR}/scale-demo/vegeta \
    && CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags '-w' -o loader \
    && cp loader ${OUTPUT_DIR} \
	&& cd ${CONTRIB_DIR}/ingress/controllers/nginx \
    && CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags "-w -X main.version=${INGRESS_CONTROLLER_VERSION} -X main.gitRepo=git@github.com:kubernetes/contrib" -o nginx-ingress-controller \
    && cp nginx-ingress-controller ${OUTPUT_DIR}
