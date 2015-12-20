### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

##### New features for v0.6.2
 - Support for Banana Pro
 - `.deb` package deployment
 - `iptables` proxying mode for `kube-proxy` should result in better performance
 - `docker` is built statically for both `ARMv6` and `ARMv7`. Optional to use in most cases.
 - **Support for HypriotOS**
 - Support for plain `systemd` OSes
 - Enabled experimental Kubernetes by default, e.g. `Jobs`, `HorizontalPodAutoscaler`
 - k8s => 1.1.3, etcd => 2.2.2, flannel => 0.5.5, registry => 2.2.1
 - **Started to hack on mainline k8s: [kubernetes/kubernetes#17981](https://github.com/kubernetes/kubernetes/issues/17981)**
 - Renamed `kube-archlinux` to the more generic `kube-systemd`
 - Small improvments and much better README
 - Bug fixes
 

##### Future improvments
 - Break out `cluster.local`, `10.0.0.10`, `10.1.0.0/16`
 - run `kube-proxy` as a static pod on worker also
 - Add a loadbalancer
 - Add the `scale-demo` project
 - Maybe add support for [HypriotOS](http://blog.hypriot.com) and Scaleway via .deb package?
 - Compile [RancherOS](https://github.com/rancher/os) to ARM
 - When dashboard is released, support it here also
 - Ability to auto-upgrade the kube-systemd package, HOW