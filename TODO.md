# TODO

 - investigate google/cadvisor
 - Kommentera allt
 - rancher os-images build
   - os-base
   - diy linux
   - cross compile os
 - docker from scratch - docker-server inte gjord
 - testa att koppla alla rpis till hubben
 - make a common luxcloud "binary"
 - insert a non-root user to raspbian and alpine
 - enable internet for flannel containers docker --ip-masq=false, flannel --ip-masq
 - why doesn't systemd time synchronization work? OK 
 - commit rancheros power.go patch OK



## TODO 11/9 -->
- docker registry up OK, testing service DONE
- k8s in systemd, ongoing, DONE
- dhcp for master node







Failed to create pod infra container: DNS ResolvConfPath specified but does not exist. It could not be updated: /var/lib/docker/containers/726c0ba32f80c452c6d794bd89aa31531022586ae443efd8ed708fdec9ea15be/resolv.conf; Skipping pod "k8s-master-k8smaster_default"

 # shortcuts

 - dockerrm_s
 - dockerclean?








BR2.*=.*










```bash
# Check if variable is "" or unset
if [ -z "$GO_VERSION" ];
```


#http://stackoverflow.com/questions/13055685/how-to-get-total-additions-and-deletions-on-a-given-branch-for-an-given-author-i
git log --shortstat | awk '/^ [0-9]/ { f += $1; i += $4; d += $6 } END { printf("%d files changed, %d insertions(+), %d deletions(-)", f, i, d) }'