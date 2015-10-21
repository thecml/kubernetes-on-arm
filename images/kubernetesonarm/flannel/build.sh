cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/flanneld .

docker build -t kubernetesonarm/flannel .