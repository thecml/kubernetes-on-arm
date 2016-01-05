### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

#### Future improvments
 - Run `kube-proxy` as a DaemonSet on worker, at least not supported before the v1.2.0 release of Kubernetes
 - Add `service-loadbalancer` from contrib
 - Add the `scale-demo` project
 - Investigate if `heapster` is lightwight enough to run on ARM
 - Is Scaleway supported now with the `.deb` package? Find out
 - When kubernetes/dashboard is released, include it here also
 - Ability to auto-upgrade the kube-systemd package