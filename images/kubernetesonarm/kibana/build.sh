cd "$( dirname "${BASH_SOURCE[0]}" )"

cp ../../version.sh .

docker build -t kubernetesonarm/kibana .
