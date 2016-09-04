### Roadmap for Kubernetes on ARM

Just some notes about what I probably will include in this project

#### Future improvements
 - Make this project unnecessary!
 - Upgrade to v1.4.0
 - Use the official `.deb` package
 - Use the `kubeadm` way of bootstrapping a cluster
 - Make the cluster setup secure and always encrypt communication with TLS between nodes
 - Use CNI for networking and self-host flannel
 - Run `kube-proxy` in a DaemonSet
 - Create official `heapster` builds and use them
 - Create official `ingress` builds and use them
 - High availability
 - Survive reboots
 - Create a prebuilt image based on HypriotOS
 - Ability to upgrade Kubernetes smoothly
 - Self-hosting
 - Ability to create SD card images for Pine64
 - Ability to set up Kubernetes without an internet connection
 - Full support for Pine64 and Scaleway
 - Support more boards: Odroid C1, C2, XU4 and Banana Pro with HypriotOS
