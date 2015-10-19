cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/kube-ui .

docker build -t kubernetesonarm/kube-ui .