### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

##### New features for v0.5.9
 - A new, more customizable way to write the SD Card, allows for more OSes in the future
 - Upgrade flannel => v0.5.4, etcd => 2.2.1, registry => 2.2.0, k8s => 1.0.7
 - Fix the bug that makes this not run on armv6, e.g. Raspberry Pi 1
 - Add a loadbalancer

##### New features for v0.6.0
 - Maybe upgrade Kubernetes to v1.1.0, depends on whether they release it as a stable version or not
 - Add some test scripts for even more automation
 - Add support for Banana Pro


##### Future improvments
 - Build the Kubernetes binaries with Go 1.5.1, when it is working
 - Maybe add support for [HypriotOS](http://blog.hypriot.com)
 - Compile [RancherOS](https://github.com/rancher/os) to ARM
 - When kube-ui (or dashboard) is released, support it here also
 - Enhance security with certs and ServiceAccounts


 TODO: check if containers has internet after kube-config enable => kube-config disable