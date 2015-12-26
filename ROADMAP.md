### Roadmap for Kubernetes-on-arm

Just some notes about what I probably will include in this project

##### Future improvments
 - Break out the DNS options `cluster.local` and `10.0.0.10`
 - Run `kube-proxy` as a DaemonSet on worker
 - Add a loadbalancer
 - Add the `scale-demo` project
 - Add more README to all of kubernetesonarm/ images and the kube-systemd filesystem
 - Is Scaleway supported now with the `.deb` package? Find out
 - When kubernetes/dashboard is released, support it here also
 - Ability to auto-upgrade the kube-systemd package