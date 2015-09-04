FROM luxas/go

# Download dockviz from github, and make the binary
RUN curl -sSL -k https://github.com/justone/dockviz/archive/master.tar.gz | tar -xz && \
	cd dockviz-master && \
	go get github.com/fsouza/go-dockerclient
	go get github.com/jessevdk/go-flags && \
	make build && \
	mv dockviz-master dockviz