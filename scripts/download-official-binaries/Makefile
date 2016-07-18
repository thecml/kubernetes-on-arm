ARCH?=arm
OUTPUT?=$(shell pwd)/bin/$(ARCH)
TMPDIR:=$(shell mktemp -d)

ETCD_VERSION = 2.2.5
FLANNEL_VERSION = 0.5.5
K8S_VERSION = v1.3.0

all: compress
compress: etcd flanneld kube
	cd $(TMPDIR)/bin && tar -czf $(OUTPUT)/kube-$(K8S_VERSION)-$(ARCH).tar.gz .

etcd: dirs
	docker export $(shell docker create gcr.io/google_containers/etcd-$(ARCH):2.2.5) | tar -x -C $(TMPDIR)/etcd
	cp $(TMPDIR)/etcd/usr/local/bin/etcd $(TMPDIR)/etcd/usr/local/bin/etcdctl $(TMPDIR)/bin/

flanneld: dirs
	docker export $(shell docker create gcr.io/google_containers/flannel-$(ARCH):0.5.5) | tar -x -C $(TMPDIR)/flannel
	cp $(TMPDIR)/flannel/opt/bin/flanneld $(TMPDIR)/bin/

kube: dirs
	curl -sSL https://storage.googleapis.com/kubernetes-release/release/$(K8S_VERSION)/bin/linux/$(ARCH)/kubectl > $(TMPDIR)/bin/kubectl
	curl -sSL https://storage.googleapis.com/kubernetes-release/release/$(K8S_VERSION)/bin/linux/$(ARCH)/hyperkube > $(TMPDIR)/bin/hyperkube
	curl -sSL https://storage.googleapis.com/kubernetes-release/release/$(K8S_VERSION)/bin/linux/$(ARCH)/e2e.test > $(TMPDIR)/bin/e2e.test
	curl -sSL https://storage.googleapis.com/kubernetes-release/release/$(K8S_VERSION)/bin/linux/$(ARCH)/e2e_node.test > $(TMPDIR)/bin/e2e_node.test

dirs:
	mkdir -p $(TMPDIR)/flannel $(TMPDIR)/etcd $(TMPDIR)/bin $(OUTPUT)
