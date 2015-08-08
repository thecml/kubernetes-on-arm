cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/flanneld .
cp /lib/ld-linux-armhf.so.3 .

docker build -t k8s/flannel .