cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

cp ../_bin/latest/pause .

docker build -t k8s/pause:$(LUX_VERSION) .