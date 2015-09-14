cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

cp ../_bin/latest/hyperkube .

docker build -t k8s/hyperkube:$LUX_VERSION .