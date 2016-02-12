### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

#### v0.6.5
 - Add an experimental loadbalancer
 - Upgrade to and support docker-1.10.0 only
 - Kubernetes Dashboard UI added as an addon
 - Experimental support for Odroid C1 on HypriotOS
 - Do not depend on pacman, use a self-built docker-1.10 binary instead
 - Revert to userspace proxying, since iptables proxying had some bugs in it

#### Future improvements
 - Run `kube-proxy` as a DaemonSet on worker, at least not supported before the v1.2.0 release of Kubernetes
 - Investigate if `heapster` is lightwight enough to run on ARM
 - Is Scaleway supported now with the `.deb` package? Find out
 - Ability to auto-upgrade the kube-systemd package
 - Investigate what happens if the master is up for one or two days => scalability tests
 - Change to `nsenter` instead of `--containerized` when it's stable
 - Fix tests that could be flaky
 - Maybe add support for Odroid XU4, Pine64, Nvidia ShieldTV
 - Add a stable `.tar.gz` deployment besides the `.deb` deployment
 - Maybe build `flannel` statically to minimize image size
 - Use `vxlan` as the backend for the `flannel` overlay network
 - Support RancherOS on ARM and make a rootfs