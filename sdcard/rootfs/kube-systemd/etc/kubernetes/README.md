### Readme for Kubernetes on ARM

v0.6.3

More docs will be included in future releases

/etc/
 - kubernetes/
   - dropins/
     - docker-flannel.conf - A dropin file which reads /var/lib/flannel/subnet.env and commands docker to use that flannel subnet. Is used when Kubernetes is running.
     - docker-overlay.conf - The "normal" dropin, which is enabled when Kubernetes isn't. Fixes a systemd bug, uses overlay and plays well with system-docker
   - dynamic-env/
     - env.conf - A file specifies which OS and board it's running on. Options: the files that are in os/ and board/. `kube-config` uses these files to e.g install docker on various platforms.
     - os/
       - Here are customization scripts for the OSes supported
     - board/
       - Here are customization scripts for the boards supported
   - static/
     - master/
       - master.json - This file is important. This is the definition of the master´s Kubernetes components, which run as a static pod
     - worker/
       - Here and in master/ you may put `.json` files and they will run as static pods
   - source/
     - This project´s source. All `kubernetes-on-arm` code is copied when the `rootfs` is packaged.
   - binaries/
     - Symlink to `source/images/kubernetesonarm/_bin/latest`
     - Here are the Kubernetes binaries stored.
   - addons/
     - Symlink to `source/addons`
   - k8s.conf - Configuration file
 - profile.d/
   - binaries-in-PATH.sh - Adds `/etc/kubernetes/binaries` to $PATH
   - system-docker.sh - Adds the `system-docker` alias
 - systemd/
   - network/
     - dns.network - A `.network` file for Arch Linux, enables DHCP for `eth0` and sets the `search` command to `/etc/resolv.conf`
   - resolved.conf.d/
     - dns.conf - Sets the `nameserver` command for `/etc/resolv.conf` for Arch Linux
/usr/
 - bin/
   - kube-config - The heavy-lifting script. May install everything required for Kubernetes, start and stop it and much more.
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
     - Kubernetes apiserver´s self-signed scripts are here
   - etcd/
     - Kubernetes data is stored here (when the master is running)
   - flannel/
     - subnet.env - Flannel subnet options
 - system-docker/
   - Same as `/var/lib/docker` but for `system-docker`
 - kubelet/
   - The `kubelet` directory
