system-docker(){
	docker -H unix:///var/run/system-docker.sock $@
}
dockerrm_s(){
	if [ -z "$1" ]
	then
		docker rm $(docker ps --filter status=exited -q)
	else
		$1 rm $($1 ps --filter status=exited -q)
	fi
}
git-stats(){
	git log --shortstat | awk '/^ [0-9]/ { f += $1; i += $4; d += $6 } END { printf("%d files changed, %d insertions(+), %d deletions(-)", f, i, d) }'
}