cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

cp ../_bin/latest/exechealthz .

docker build -t k8s/exechealthz:$LUX_VERSION .