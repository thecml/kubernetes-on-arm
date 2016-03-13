cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/aggregator .

docker build -t kubernetesonarm/aggregator .
