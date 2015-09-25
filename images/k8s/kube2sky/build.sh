cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

cp ../_bin/latest/kube2sky .

docker build -t k8s/kube2sky:$LUX_VERSION .