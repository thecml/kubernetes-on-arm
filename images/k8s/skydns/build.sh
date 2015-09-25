cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

cp ../_bin/latest/skydns .

docker build -t k8s/skydns:$LUX_VERSION .