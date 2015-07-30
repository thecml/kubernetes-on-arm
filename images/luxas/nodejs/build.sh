#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

docker build -t luxas/nodejs-build .

../../../utils/strip-image/strip-docker-image \
	-i luxas/nodejs-build \
	-p node \
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