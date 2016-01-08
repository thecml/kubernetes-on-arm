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
 - Investigate what happens if the master is up for one or two days
 - Change to `nsenter` instead of `--containerized` when it's stable
 - Build docker 1.9.1 statically for ARMv6 with go1.4.3
 - Fix tests that could be flaky
 - Maybe add support for Odroid C1, XU3 and XU4