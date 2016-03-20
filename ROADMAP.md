### Roadmap for Kubernetes on ARM

Just some notes about what I probably will include in this project

#### v0.7.0
 - Upgrade to Kubernetes v1.2.0 [Changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md), dashboard v1.0.0, etcd v2.2.5, registry v2.3.1
 - Using "official" binaries from my Kubernetes PR: [kubernetes/kubernetes#19769](https://github.com/kubernetes/kubernetes/pull/19769)
 - Added cluster monitoring! Heapster v1.0.0, influxdb v0.10.3 and grafana v2.6.0
 - Changed to "native" kubelet mode. No more `--containerized` hack. Makes it possible to use Downward API
 - Switched to `host-gw` instead of `udp` as the default `flannel` backend for improved performance as [@larmog](https://github.com/larmog) suggested. Also made the option `FLANNEL_BACKEND` in `k8s.conf`
 - Compile `flannel` and `registry` statically. That reduces their total image size 147 MB
 - Deprecated and removed `luxas/raspbian` in favor for plain `resin/rpi-raspbian:jessie`
 - Added `master.json` to the hyperkube image so it's easy to spin up a one-node cluster as `docker.md` in official docs does.
 - Using @hypriot's prebuilt Go tarballs for `luxas/go`. Will switch to official `go1.6` soon.
 - Added experimental RancherOS to `sdcard/write.sh`, but no Kubernetes rootfs is available yet
 - Made the storage driver easily changeable with the `DOCKER_STORAGE_DRIVER` in `/etc/kubernetes/k8s.conf`
 - Changed indentation to spaces instead of tabs for the most of the files. Also trying to end all files with a newline.
 - Replaced `sleep` based timeouts in kube-config for condition based loops, makes it faster and more reliable
 - Added a debugging option in `kube-config` by specifying `K8S_DEBUG=1` before the command.
 - Fixed a HypriotOS/`.deb`-file issue where `sudo` modified the `$PATH` so `kube-config` couldn't find `kubectl` [@DorianGray](https://github.com/DorianGray)
 - More reliable SD Card creation by using `partprobe` [@DorianGray](https://github.com/DorianGray)
 - Lowered the `nodeMonitorGracePeriod` and the `podEvictionTimeout` as [@saturnism](https://github.com/saturnism) suggests
 - Changed proxying mode to `iptables` for better performance.

#### Future improvements
 - Run `kube-proxy` as a DaemonSet on worker, at least not supported before the v1.2.0 release of Kubernetes
 - Is Scaleway supported now with the `.deb` package? Find out
 - Ability to auto-upgrade the kube-systemd package
 - Scalability and e2e tests
 - Maybe add support for Odroid C1, C2, XU4, Pine64, Nvidia ShieldTV. The problem is old kernels.
 - Add a stable `.tar.gz` deployment besides the `.deb` deployment
 - Support RancherOS on ARM and make a rootfs
 - Add a catalog with prebuilt apps that integrate well with Kubernetes and may be used as demos
