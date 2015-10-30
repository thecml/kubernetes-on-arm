### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

##### New features for v0.6.0
 - A new, more customizable way to write the SD Card, allows for more OSes in the future
 - Upgrade flannel to v0.5.4
 - Maybe upgrade Kubernetes to v1.1.0, depends on whether they release it as a stable version or not
 - Add some test scripts for even more automation
 - Build the Kubernetes binaries with Go 1.5.1
 - Add support for Banana Pro


##### Future improvments
 - Add a loadbalancer
 - Fix the bug that makes this not run on armv6, e.g. Raspberry Pi 1
 - Maybe add support for [HypriotOS](http://blog.hypriot.com)
 - Compile [RancherOS](https://github.com/rancher/os) to ARM
 - When kube-ui is released, support it here also
 - Enhance security with certs and ServiceAccounts