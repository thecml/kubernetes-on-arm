### Readme for Kubernetes on ARM

v0.6.2

More docs will be included in future releases

/etc/
 - kubernetes/
   - dropins/
     - docker-flannel.conf - A dropin file which reads /var/lib/flannel/subnet.env and commands docker to use that flannel subnet
     - docker-overlay.conf - The "normal" dropin, which is enabled when kubernetes isn't. Fixes a systemd bug, uses overlay and plays well with system-docker
   - dynamic-env/
     - env.conf - 
     - ...
   - static/
     - master/
       - master.json - This file is important. This is the definition of the master´s Kubernetes components, which run as a static pod
     - worker/
       - Here and in master/ you may put `.json` files and they will run as static pods
   - source/
     - This project´s source. All `kubernetes-on-arm` code copied when the `rootfs` was packaged.
   - binaries/
     - symlink to `source/images/kubernetesonarm/_bin/latest`
   - addons/
     - symlink to `source/addons`
   - k8s.conf - Configuration file
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
