cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../_bin/latest/pause .

docker build -t kubernetesonarm/pause .
