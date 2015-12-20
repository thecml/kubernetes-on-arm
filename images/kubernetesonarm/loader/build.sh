cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/loader .

docker build -t kubernetesonarm/loader .