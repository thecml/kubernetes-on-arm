ARCH?=arm
OUTPUT?=$(shell pwd)/bin/$(ARCH)
TMPDIR:=$(shell mktemp -d)

ETCD_VERSION = 2.2.5
FLANNEL_VERSION = v0.6.1
K8S_VERSION = v1.3.6

all: compress
compress: etcd flanneld kube
	cd $(TMPDIR)/bin && tar -czf $(OUTPUT)/kube-$(K8S_VERSION)-$(ARCH).tar.gz .

etcd: dirs
	docker export $(shell docker create gcr.io/google_containers/etcd-$(ARCH):$(ETCD_VERSION)) | tar -x -C $(TMPDIR)/etcd
	cp $(TMPDIR)/etcd/usr/local/bin/etcd $(TMPDIR)/etcd/usr/local/bin/etcdctl $(TMPDIR)/bin/

flanneld: dirs
	docker export $(shell docker create quay.io/coreos/flannel:$(FLANNEL_VERSION)-$(ARCH)) | tar -x -C $(TMPDIR)/flannel
	cp $(TMPDIR)/flannel/opt/bin/flanneld $(TMPDIR)/bin/

kube: dirs
	curl -sSL https://storage.googleapis.com/kubernetes-release/release/$(K8S_VERSION)/bin/linux/$(ARCH)/kubectl > $(TMPDIR)/bin/kubectl
	curl -sSL https://storage.googleapis.com/kubernetes-release/release/$(K8S_VERSION)/bin/linux/$(ARCH)/kubelet > $(TMPDIR)/bin/kubelet
	curl -sSL https://storage.googleapis.com/kubernetes-release/release/$(K8S_VERSION)/bin/linux/$(ARCH)/hyperkube > $(TMPDIR)/bin/hyperkube

dirs:
	mkdir -p $(TMPDIR)/flannel $(TMPDIR)/etcd $(TMPDIR)/bin $(OUTPUT)
