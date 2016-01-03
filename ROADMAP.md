### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

### v0.6.3
 - Fix bugs and make the `.deb` file stable
 - Add a `.tar.gz` deployment for platforms that doesn't have `dpkg`
 - Document the /etc/kubernetes/README.md better
 - Refactor and remove unnecessary things
 - Break out the DNS options `cluster.local` and `10.0.0.10` to `/etc/kubernetes/k8s.conf`


#### Future improvments
 - Run `kube-proxy` as a DaemonSet on worker, at least not supported before the v1.2.0 release of Kubernetes
 - Add a loadbalancer
 - Add the `scale-demo` project
 - Investigate if `heapster` is lightwight enough to run on ARM
 - Add more README to all of kubernetesonarm/ images and the kube-systemd filesystem
 - Is Scaleway supported now with the `.deb` package? Find out
 - When kubernetes/dashboard is released, support it here also
 - Ability to auto-upgrade the kube-systemd package