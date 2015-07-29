#!/bin/bash

docker build -t luxas/nodejs-build .

../../utils/strip-image/strip-docker-image \
	-i luxas/nodejs-build \
	-p nodejs \
	-t luxas/nodejs \
	-f /etc/passwd \
	-f /etc/group \
	-f '/lib/*/libnss*' \
	-f /bin/ls \
	-f /bin/cat \
	-f /bin/sh \
	-f /bin/mkdir \
	-f /bin/ps \
	-f /var/run 