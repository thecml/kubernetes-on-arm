# Possible FROM scratch, but harder to debug
FROM luxas/alpine

COPY etcd etcdctl /usr/bin/

RUN mkdir /var/lib/etcd

CMD ["/usr/bin/etcd", "--addr=127.0.0.1:4001", "--bind-addr=0.0.0.0:4001", "--data-dir=/var/etcd/data"]