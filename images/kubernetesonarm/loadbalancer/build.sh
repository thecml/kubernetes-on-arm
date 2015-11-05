cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/service-loadbalancer .

docker build -t kubernetesonarm/loadbalancer .