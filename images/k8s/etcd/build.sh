cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

cp ../_bin/latest/etcd .
cp ../_bin/latest/etcdctl .

docker build -t k8s/etcd:$LUX_VERSION .