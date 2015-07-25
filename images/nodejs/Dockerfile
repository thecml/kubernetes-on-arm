FROM luxas/raspbian

RUN apt-install wget \
 	&& cd /tmp \
	&& wget http://node-arm.herokuapp.com/node_latest_armhf.deb \
	&& dpkg -i node_latest_armhf.deb \
	&& rm node_latest_armhf.deb

