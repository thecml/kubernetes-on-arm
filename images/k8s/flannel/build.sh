cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/flanneld .

docker build -t k8s/flannel .

#../../../utils/strip-image/strip-docker-image \
#	-i k8s/flannel-build \
#	-p flanneld \
#	-t k8s/flannel \
#	-f /etc/passwd \
#	-f /etc/group \
#	-f '/lib/*/libnss*' \
#	-f /bin/ls \
#	-f /bin/cat \
#	-f /bin/sh \
#	-f /bin/mkdir \
#	-f /bin/ps \
#	-f /var/run \
#	-f /flanneld