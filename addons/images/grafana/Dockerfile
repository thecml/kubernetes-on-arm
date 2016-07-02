FROM armel/busybox

ADD grafana.tar /
COPY pods.json cluster.json /dashboards/
COPY gosu /usr/sbin/
COPY run.sh /

ENTRYPOINT ["/run.sh"]
