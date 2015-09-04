FROM       scratch

# Add content to the image
ADD ./rootfs.tar.xz /
ADD ./scripts/apk-install /usr/sbin/apk-install

# Base packages useful for other containers
RUN apk update && \
	apk upgrade && \
	chmod +x /usr/sbin/apk-install && \
	apk-install ca-certificates curl wget

CMD ["/bin/sh"]