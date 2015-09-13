cd "$( dirname "${BASH_SOURCE[0]}" )"

source ../../version.sh

docker build -t luxas/bench:$(LUX_VERSION) .