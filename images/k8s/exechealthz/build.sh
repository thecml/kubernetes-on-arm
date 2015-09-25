cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/exechealthz .

docker build -t k8s/exechealthz .