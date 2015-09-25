cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/skydns .

docker build -t k8s/skydns .