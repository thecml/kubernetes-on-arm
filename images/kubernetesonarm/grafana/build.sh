cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/grafana-server .

curl -sSL https://raw.githubusercontent.com/kubernetes/heapster/master/grafana/dashboards/cluster.json > cluster.json
curl -sSL https://raw.githubusercontent.com/kubernetes/heapster/master/grafana/dashboards/pods.json > pods.json

docker build -t kubernetesonarm/grafana .
