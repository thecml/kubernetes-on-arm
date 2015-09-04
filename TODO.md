# TODO

 - investigate google/cadvisor
   - build for kubemaster
 - Kommentera allt
 - rancher os-images build
   - os-base
   - diy linux
   - cross compile os
 - docker from scratch - docker-server inte gjord
 - testa att koppla alla rpis till hubben
 - make a common luxcloud "binary"
 - insert a non-root user to raspbian and alpine
 //- controller-manager --machines specification, for it to come up
 - enable internet for flannel containers docker --ip-masq=false, flannel --ip-masq
 - why doesn't systemd time synchronization work?
 - commit rancheros power.go patch




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