### Readme for the Kubernetes on ARM root filesystem

v0.8.0

/etc/
 - kubernetes/
   - dropins/
     - docker-flannel.conf - A dropin file which reads /var/lib/flannel/subnet.env and commands docker to use that flannel subnet. Is used when Kubernetes is running.
     - docker-overlay.conf - The "normal" dropin, which is enabled when Kubernetes isn't. Fixes a systemd bug, uses overlay and plays well with system-docker
   - env/
     - env.conf - A file specifies which OS and board it's running on. Options: the files that are in os/ and board/. `kube-config` uses these files to e.g install docker on various platforms.
     - os/
       - Here are customization scripts for the OSes supported
     - board/
       - Here are customization scripts for the boards supported
   - source/
     - This project´s source. All `kubernetes-on-arm` code is copied when the `rootfs` is packaged.
   - addons/
     - Symlink to `source/addons`
   - k8s.conf - Configuration file for this project
 - profile.d/
   - binaries-in-PATH.sh - Adds `/etc/kubernetes/binaries` to $PATH
   - system-docker.sh - Adds the `system-docker` alias
 - systemd/
   - network/
     - dns.network - A `.network` file for Arch Linux, enables DHCP for `eth0`, sets the `search` and `nameserver` commands to `/etc/resolv.conf`


/usr/
 - bin/
   - kube-config - The heavy-lifting script. May install everything required for Kubernetes, start and stop it and much more.
/var/lib
 - docker-bootstrap/
   - Same as `/var/lib/docker` but for `system-docker`
 - kubelet/
   - The `kubelet` directory
