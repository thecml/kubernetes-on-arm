cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

docker build -t luxapp/lxde:$LUX_VERSION .