system-docker(){
    docker -H unix:///var/run/system-docker.sock "$@"
}
docker-bootstrap(){
    docker -H unix:///var/run/system-docker.sock "$@"
}
docker-rm-stopped(){ 
    docker rm $(docker ps --filter status=exited -q) 
}
