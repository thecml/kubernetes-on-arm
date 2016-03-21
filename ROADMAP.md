### Roadmap for Kubernetes on ARM

Just some notes about what I probably will include in this project

#### Future improvements
 - Run `kube-proxy` as a DaemonSet on worker, at least not supported before the v1.2.0 release of Kubernetes
 - Is Scaleway supported now with the `.deb` package? Find out
 - Ability to auto-upgrade the kube-systemd package
 - Scalability and e2e tests
 - Maybe add support for Odroid C1, C2, XU4, Pine64, Nvidia ShieldTV. The problem is old kernels.
 - Add a stable `.tar.gz` deployment besides the `.deb` deployment
 - Support RancherOS on ARM and make a rootfs
 - Add a catalog with prebuilt apps that integrate well with Kubernetes and may be used as demos
