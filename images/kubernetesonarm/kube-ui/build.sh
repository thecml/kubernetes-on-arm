cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/kube2sky .

docker build -t kubernetesonarm/kube2sky .