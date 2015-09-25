cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/kube2sky .

docker build -t k8s/kube2sky .