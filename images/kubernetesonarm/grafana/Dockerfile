FROM resin/rpi-raspbian:jessie

RUN apt-get update && apt-get -y --no-install-recommends install \
        libfontconfig \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# TODO: read grafana version
RUN dpkg --add-architecture amd64 \
    && curl -sSL https://grafanarel.s3.amazonaws.com/builds/grafana_2.6.0_amd64.deb > /tmp/grafana.deb \
    && dpkg --force-all -i /tmp/grafana.deb \
    && rm /tmp/grafana.deb /usr/sbin/grafana-server \
    && curl -sSL https://github.com/tianon/gosu/releases/download/1.7/gosu-armel > /usr/sbin/gosu \
    && chmod +x /usr/sbin/gosu

COPY pods.json cluster.json /dashboards/
COPY run.sh /
COPY grafana-server /usr/sbin/grafana-server

ENTRYPOINT ["/run.sh"]
