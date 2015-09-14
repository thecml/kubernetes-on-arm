#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

docker build -t build/docker-client .


# Only a docker client
../../../utils/strip-image/strip-docker-image \
	-i build/docker-client \
	-p docker \
	-t luxas/docker-client:$LUX_VERSION \
	-f /etc/passwd \
	-f /etc/group \
	-f '/lib/*/libnss*' \
	-f /bin/ls \
	-f /bin/cat \
	-f /bin/sh \
	-f /bin/mkdir \
	-f /bin/ps \
	-f /var/run \
	-f /etc/ssl \
	-f /usr/bin/modprobe \
	-f /usr/bin/iptables \
	-f /usr/bin/xz \
	-f /usr/bin/ps \
	-f /usr/bin/docker