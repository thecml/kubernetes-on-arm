FROM luxas/alpine

RUN apk-install nodejs

RUN curl -sSL https://download.elastic.co/kibana/kibana/kibana-4.5.0-linux-x64.tar.gz | tar -xz \
	&& mv kibana* kibana \
	&& rm -r kibana/node

CMD ["node", "kibana/cmd/cli", "-e", "localhost:9200"]
