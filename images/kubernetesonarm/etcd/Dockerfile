FROM luxas/alpine

COPY etcd etcdctl /usr/local/bin/

CMD ["/usr/local/bin/etcd", "--listen-client-urls=http://127.0.0.1:4001", "--advertise-client-urls=http://127.0.0.1:4001", "--data-dir=/var/etcd/data"]