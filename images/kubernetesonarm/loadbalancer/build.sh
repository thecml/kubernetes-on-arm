cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/service_loadbalancer .

docker build -t kubernetesonarm/loadbalancer .
