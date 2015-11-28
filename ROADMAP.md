### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

##### New features for v0.6.0
 - A new, more customizable way to write the SD Card, allows for more OSes in the future
   - Automates post-installation for cubietruck.
 - Upgrade k8s => 1.1.2, flannel => v0.5.4, etcd => 2.2.1, registry => 2.2.0, go => 1.4.3
 - Now it's possible to build the Kubernetes binaries with Go 1.5.1, but it's much slower so it's not default
 - Add some test scripts for even more automation
 - Fix the bug that makes this not run on armv6, e.g. Raspberry Pi 1
 - Add windows downloads
 - Now `ServiceAccount` `secrets` are working as they should
   - Make dns use ServiceAccount tokens
 - `kube-proxy` runs in a container under `kubelet`

##### New features for v0.6.2
 - Add README to all of kubernetesonarm/ images and the kube-archlinux filesystem
 - Add a loadbalancer
 - A .deb package?
 - Ability to auto-upgrade the kube-archlinux package
 - Break out `cluster.local`, `10.0.0.10`, `10.1.0.0/16`
 - Automatically use `iptables` proxying.
 - Maybe build docker statically for both `armv6` and `armv7` => Remove dependency on `pacman`

##### Future improvments
 - Add support for Banana Pro
 - Maybe add support for [HypriotOS](http://blog.hypriot.com) and Scaleway via .deb package?
 - Compile [RancherOS](https://github.com/rancher/os) to ARM
 - When dashboard is released, support it here also