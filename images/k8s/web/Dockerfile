FROM luxas/nodejs

VOLUME ["/www"]

COPY onstart.sh /usr/bin/onstart.sh

RUN mkdir /www && \
	npm install -g bower http-server && \
	chmod +x /usr/bin/onstart.sh

WORKDIR ["/www"]
CMD ["/usr/bin/onstart.sh"]