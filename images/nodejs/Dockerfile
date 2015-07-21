FROM resin/rpi-raspbian

RUN apt-get update \
	&& apt-get install wget -y \
	&& apt-get autoclean \
    && apt-get autoremove \
    && rm -r /var/cache/apt/* /var/lib/apt/lists/*

RUN cd /tmp \
	&& wget http://node-arm.herokuapp.com/node_latest_armhf.deb \
	&& dpkg -i node_latest_armhf.deb \
	&& rm node_latest_armhf.deb

