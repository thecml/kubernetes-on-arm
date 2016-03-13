cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/registry .

docker build -t kubernetesonarm/registry .
