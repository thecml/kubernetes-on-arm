### Readme for the Kubernetes on ARM root filesystem

v0.8.0

/etc/
 - kubernetes/
   - addons/
     - Kubernetes on ARM-specific addons
   - env/
     - env.conf - A file specifies which OS and board it's running on. Options: the files that are in os/ and board/. `kube-config` uses these files to e.g install docker on various platforms.
     - os/
       - Here are customization scripts for the OSes supported
     - board/
       - Here are customization scripts for the boards supported
   - kube-deploy/
     - A git clone of https://github.com/kubernetes/kube-deploy
   - k8s.conf - Configuration file for this project
 - profile.d/
   - system-docker.sh - Adds the `docker-bootstrap` alias
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
