# Possible FROM scratch, but harder to debug
FROM luxas/alpine

COPY etcd etcdctl /usr/bin/

RUN mkdir /var/lib/etcd

CMD ["/usr/bin/etcd", "--listen-client-urls=http://127.0.0.1:4001", "--advertise-client-urls=http://127.0.0.1:4001", "--data-dir=/var/etcd/data"]