cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

docker build -t luxas/nginx:$LUX_VERSION .