### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

##### New features for v0.6.0
 - A new, more customizable way to write the SD Card, allows for more OSes in the future
   - Automate post-installation for cubietruck also.
 - Upgrade Kubernetes to v1.2.0-latest
 - Upgrade flannel => v0.5.4, etcd => 2.2.1, registry => 2.2.0, go => 1.4.3
 - Now it's possible to build the Kubernetes binaries with Go 1.5.1, but it's much slower so it's not default
 - Add some test scripts for even more automation
 - Fix the bug that makes this not run on armv6, e.g. Raspberry Pi 1
 - Add README to all of kubernetesonarm/ images and the kube-archlinux filesystem
 - Add windows downloads
 - Enhance security with certs and ServiceAccounts
 - Add a loadbalancer

##### Future improvments
 - Add support for Banana Pro
 - A .deb package?
   - Maybe add support for [HypriotOS](http://blog.hypriot.com) via .deb package?
 - Compile [RancherOS](https://github.com/rancher/os) to ARM
 - When dashboard is released, support it here also
 