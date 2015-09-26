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
countlines(){
	find . -type f -name '*.*' -exec cat {} \; | sed '/^\s*$/d' | wc -l
}
countlines_nocomment(){
	find . -type f -name '*.*' -exec cat {} \; | sed '/^\s*#/d;/^\s*$/d;/^\s*\/\//d' | wc -l
}
copyimage(){
	cat <<EOF
$1: image to transfer to another host
$2: ip address: 192.168.1.$2
EOF
	docker save $1 | pv | ssh root@192.168.1.$2 "docker load"
}