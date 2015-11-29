# README for Arch Linux ARM with Kubernetes enabled

v0.6.0

More docs will be included in future releases

/etc/
 - kubernetes/
   - dropins/
     - docker-flannel.conf - A dropin file which reads /var/lib/flannel/subnet.env and commands docker to use that flannel subnet
     - docker-overlay.conf - The "normal" dropin, which is enabled when kubernetes isn't. Fixes a systemd bug, uses overlay and plays well with system-docker
   - dynamic-env/
     - env.conf
     - ...
   - static/
     - master/
       - master.json
     - worker/
       - 
   - source/
     - ...
   - binaries/
     - symlink to source/images/kubernetesonarm/_bin/latest
   - addons/
     - symlink to source/addons
   - k8s.conf
 - profile.d/
   - binaries-in-PATH.sh 
   - system-docker.sh
 - systemd/
   - network/
     - dns.network
   - resolved.conf.d/
     - dns.conf
/usr/
 - bin/
   - kube-config
 - lib/systemd/system
   - etcd.service
   - flannel.service
   - k8s-master.service
   - k8s-worker.service
   - system-docker.service
   - system-docker.socket
/var/lib
 - kubernetes/
   - certs/
     - ...
   - etcd/
     - ...
   - flannel/
     - subnet.env
 - system-docker/
   - ...
 - kubelet/
   - ...
