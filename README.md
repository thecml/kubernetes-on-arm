## Welcome to the Kubernetes on ARM project!

#### Kubernetes on a Raspberry Pi? Is that possible?

#### Yes, now it is.    
Imagine... Your own testbed for Kubernetes with cheap Raspberry Pis and friends. 

![Image of Kubernetes and Raspberry Pi](docs/raspberrypi-joins-kubernetes.png)

#### **Are you convinced too, like me, that cheap ARM boards and Kubernetes is a match made in heaven?**    
**Then, lets go!**

## Important information

This project was published in September 2015 as the first fully working way to easily set up Kubernetes on ARM devices.

I worked on making it better non-stop until early 2016, when I started contributing the changes I've made back to Kubernetes core.
I strongly think that most of these features belong to the core, so everyone may take advantage of it, and so Kubernetes can be ported to even more platforms.

So I opened [kubernetes/kubernetes#17981](https://github.com/kubernetes/kubernetes/issues/17981) and started working on making Kubernetes cross-platform.
To date I've ported the Kubernetes core to ARM, ARM 64-bit and PowerPC 64-bit Little-endian. Already in `v1.2.0` binaries were released for ARM, and I used the official binaries in `v0.7.0` in Kubernetes on ARM.

Since `v1.3.0-alpha.3` the `hyperkube` image has been built for both `arm` and `arm64`, which have made it possible to run Kubernetes officially the "kick the tires way".
So it has been possible to run `v1.3.x` Kubernetes on Raspberry Pi´s (or whatever arm or arm64 device that runs docker) with the [docker-multinode](https://github.com/kubernetes/kube-deploy/tree/master/docker-multinode) deployment!

I've written a proposal about how to make Kubernetes available for multiple platforms [here](https://github.com/kubernetes/kubernetes/pull/26863)

*And then I became a Kubernetes maintainer in April!* :smile:

This means I have not had any extra time for maintaining Kubernetes on ARM when I instead made these features available in the core.

### So what should I use Kubernetes on ARM for now then?

Kubernetes on ARM will still serve as a out-of-the-box solution that builds upon the Kubernetes core features. For example: A SD Card writing process for Raspberry Pi`s with Kubernetes prebaked will never reach the core, but it`s a great feature here.

Also, addons will first be ported to ARM in this project, then proposed to the official project.

**OK, are you ready now to put your ARM boards to work? Then let´s go!**

## Download and build a SD Card

The first thing you will do, is to create a SD Card for your Pi. Alternatively, you may use the [`.deb` deployment](#deb-deployment)

Supported OSes/boards:
- Arch Linux ARM **(archlinux)**
  - Raspberry Pi 1 A, A+, B, B+, (ZERO,) armv6 **(rpi)**
  - Raspberry Pi 2 Model B, armv7 **(rpi-2)**
  - Raspberry Pi 3 Model B, armv8, _armv7 rootfs_ **(rpi-3)**
  - Parallella armv7, [read more](docs/parallella-status.md) **(parallella)**
  - Cubietruck, armv7 **(cubietruck)**
  - Banana Pro, armv7 **(bananapro)**
- HypriotOS **(hypriotos)**
  - Raspberry Pi 1 A, A+, B, B+, armv6 **(rpi)**
  - Raspberry Pi 2 Model B, armv7 **(rpi-2)**
  - Raspberry Pi 3 Model B, armv8, _armv7 rootfs_ **(rpi-3)**


```bash
# Go to our home folder, if you want
cd ~

# Install git if needed and download this project
# sudo apt-get install git
git clone https://github.com/luxas/kubernetes-on-arm

# Change to that directory
cd kubernetes-on-arm

# See which letter your newly inserted SD Card has:
sudo fdisk -l

# Another great command
lsblk

# Get some help text about supported options
sdcard/write.sh

# Template:
sudo sdcard/write.sh /dev/sdX [board] [os] [rootfs]

# Example: Write the SD Card for Raspberry Pi 2, Arch Linux ARM and include this project's Kubernetes scripts
sudo sdcard/write.sh /dev/sdX rpi-2 archlinux docker-multinode

# The installer will ask you if you want to erase all data on your card
# Answer y/n on that question
# Prepend the command with QUIET=1 if no security check should be made
# Requires an internet connection
# This script runs in 3-4 mins
```

The README for the `docker-multinode` rootfs [is here](sdcard/rootfs/docker-multinode/etc/kubernetes/README.md)

## Setup your board from an SD Card

Boot your board and log into it.    

Arch Linux users: 
 - The user/password is: **root/root** or **alarm/alarm**        
 - These scripts requires root. So if you login via **alarm**, then `su root` when you´re going to do some serious hacking :)

HypriotOS users:
 - The user/password is: **pirate/hypriot**
 - Remember to prepend all commands with `sudo` if you are the `pirate` user
   

Yes, I know. Root enabled via ssh isn´t that good.
But the task to enhance ssh security is left as an exercise to the user.  

```bash
# This script will install and setup docker etc.
kube-config install

# First, it will install docker, if not present
# Then it will download kube deploy

# It will ask for which hostname you want. Defaults to kubepi.

# The script will ask you for timezone. Defaults to Europe/Helsinki
# Run "timedatectl list-timezones" before to check for values

# It will ask you if it should create a 1 GB swapfile.

# Last question is whether you want to reboot
# You have to reboot in order to get the cgroups working

# If you want to run this script non-interactively, do this:
# TIMEZONE=Europe/Helsinki SWAP=1 NEW_HOSTNAME=mynewpi REBOOT=0 kube-config install
# This script runs in 2-3 mins
```

## Start Kubernetes!

Hmm, starting a complex system like Kubernetes should be a complex task, right?
Well, not this time.

```bash
# To set up your board as both a master and a node, run
kube-config enable-master

# To set up your board as a node, run
kube-config enable-worker [master-ip]
```

## Package deployment
If you have already made a SD Card and your device is up and running, what can you do instead?
For that, I've made a `.deb` package, so you could install it easily

The README for the `docker-multinode` rootfs [is here](sdcard/rootfs/docker-multinode/etc/kubernetes/README.md)

If you already have set up your Pi with latest Raspbian OS for example, follow this guide.

#### Install the `.deb` package
```bash
# The OS have to be systemd based, e. g. HypriotOS, Debian Jessie, Arch Linux ARM, Ubuntu 15.04

# Download the latest package
curl -sSL https://github.com/luxas/kubernetes-on-arm/releases/download/v0.8.0/docker-multinode.deb > docker-multinode.deb
# or
wget https://github.com/luxas/kubernetes-on-arm/releases/download/v0.8.0/docker-multinode.deb

# Requires dpkg, which is preinstalled in at least all Debian/Ubuntu OSes
sudo dpkg -i docker-multinode.deb

# Setup the enviroinment
# It will ask which board it's running on and which OS
# If your OS is Hypriot or Arch Linux, choose that. Otherwise, choose systemd, which is generic
# It will download prebuilt binaries
# And make a swap file if you plan to compile things
# A reboot is required for it to function properly
kube-config install

## ----- REBOOT -----

# Start the master or worker
kube-config enable-master
kube-config enable-worker [master ip]

# Get some info about the node
kube-config info
```


## Use Kubernetes (the fun part begins here)

Some notes on running Docker on ARM are [here](docs/docker-on-arm.md)

```bash
# See which commands kubectl and kube-config has
kubectl
kube-config

# Get info about your machine and Kubernetes version
kube-config info

# Make an replication controller with an image
# Hopefully you will have some workers, so you is able to see how they spread across hosts
# The nginx-test image will be downloaded from Docker Hub and is a nginx server which only is serving the message: "<p>WELCOME TO NGINX</p>"
# Expose the replication controller "my-nginx" as a service
kubectl run my-nginx --image=luxas/nginx-test --replicas=3 --expose --port=80

# The above command will make a deployment since v1.2. The deployment will run a replica set (the "new" kind of replication contoller)
# You may also specify --hostport, e.g. --hostport=30001 for exposing the service on all nodes' port 30001

# The pull might take some minutes
# See when the nginx container is running
docker ps

# See which pods are running
kubectl get pods

# See which nodes we have
kubectl get nodes

# See which ip we may ping, by getting services
kubectl get svc

# See if the nginx container is working
# Replace $SERVICE_IP with the ip "kubectl get svc" returned 
curl $SERVICE_IP
# --> <p>WELCOME TO NGINX</p>

# 10.0.0.10 is already enabled as a DNS server in your system, see the file /etc/systemd/resolved.conf.d/dns.conf
# That file makes /etc/resolv.conf use kube-dns also outside of your containers
kube-config enable-addon dns

# See which internal cluster services that are running
kubectl --namespace=kube-system get pods,rc,svc

# Test dns
curl my-nginx.default.svc.cluster.local
# --> <p>WELCOME TO NGINX</p>

# By default, "search [domains]" is added to /etc/resolv.conf
# In this case, these domains are searched: "default.svc.cluster.local svc.cluster.local cluster.local"
# That means, that you may only write "my-nginx", and it will search in those domains
curl my-nginx
# --> <p>WELCOME TO NGINX</p>

# Start the registry
kube-config enable-addon registry

# Wait a minute for it to start
kubectl --namespace=kube-system get pods

# Tag an image
docker tag my-name/my-image registry.kube-system:5000/my-name/my-image

# And push it to the registry
docker push registry.kube-system:5000/my-name/my-image

# On another node, pull it
docker pull registry.kube-system:5000/my-name/my-image

# The registry address may be written longer if search isn't specified.
# registry.kube-system.svc.cluster.local == registry.kube-system

# The master also proxies the services so that they are accessible from outside
# The -L flag is there because curl has to follow redirects
# You may also type this URL in a web browser
curl -L http://[master-ip]:8080/api/v1/proxy/namespaces/default/services/my-nginx

# Generic apiserver proxy URL
# curl -L http://[master-ip]:8080/api/v1/proxy/namespaces/[namespace]/services/[service-name]:[port-name]

# See which ports are open
netstat -nlp

# See cluster info
kubectl cluster-info

# See master health in a web browser
# cAdvisor in kubelet provides a web site that outputs all kind of stats in real time
# http://$MASTER_IP:4194

# Disable this node. This always reverts the "kube-config enable-*" commands
kube-config disable-node

# Remove the data for the cluster
kube-config delete-data
```


## Addons

To enable/disable addons is very easy: `kube-config enable-addon [addon-name]` and `kube-config disable-addon [addon-name]`
[README for the addons](addons/README.md)

Three addons are available for the moment:
 - Kubernetes DNS:
   - Every service gets the hostname: `{{my-svc}}.{{my-namespace}}.svc.cluster.local`
   - The default namespace is `default` (surprise), so unless you manually edit something it will land there
   - Kubernetes internal addon services runs in the namespace `kube-system`
   - Example: `my-awesome-webserver.default.svc.cluster.local` or just `my-awesome-webserver` may resolve to ip `10.0.0.154`
   - Those DNS names is available both in containers and on the node itself (kube-config automatically adds the info to `/etc/resolv.conf`)
   - If you want to access the Kubernetes API easily, `curl -k https://kubernetes` or `curl -k https://10.0.0.1` if you remember numbers better (`-k` stands for insecure as apiserver has no signed certs by default)
   - The DNS server itself has allocated ip `10.0.0.10` by default
   - The DNS domain is `cluster.local` by default
 - Central image registry:
   - A registry for storing cluster images if e.g. the cluster has no internet connection for a while
   - Or for cluster-specific images that one not want to publish on Docker Hub
   - This service is available at this address: `registry.kube-system` when DNS is enabled
   - Just tag your image: `docker tag my-name/my-image registry.kube-system:5000/my-name/my-image`
   - And push it to the registry: `docker push registry.kube-system:5000/my-name/my-image`
 - Kubernetes Dashboard:
   - The Kubernetes Dashboard project [is here](https://github.com/kubernetes/dashboard)
   - Replaces `kube-ui`
   - Access the dashboard on: `http://[master-ip]:8080/ui`
 - The Service Loadbalancer:
   - Documentation [here](https://github.com/kubernetes/contrib/tree/master/service-loadbalancer)
   - You have to label at least one node `role=loadbalancer` like this: `kubectl label no [node_ip] role=loadbalancer`
   - The loadbalancer will expose http services in the default namespace on `http://[loadbalancer_ip]/[service_name]`. Only `http` services on port 80 are tested in this release. It should be pretty easy to add `https` support though.
   - You may see `haproxy` stats on `http://[loadbalancer_ip]:1936`
   - More info will come later
 - Cluster monitoring with heapster, influxdb and grafana
   - When running this addon (`heapster`), the Dashboard will show usage graphs in the CPU and RAM columns.
   - All heapster data is stored in an InfluxDB database. Data is written once a minute. Access the graphical InfluxDB UI: `http://[master-ip]:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb:http` and the raw api on: `http://[master-ip]:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb:api`
   - A nice `grafana` web dashboard that shows resource usage for the whole cluster as for individual pods is accessible at: `http://[master-ip]:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana`. It may take some minutes for data to show up.

## Access your cluster

Here is some ways to make your outside devices reach the services running in the cluster.

 - `apiserver` proxy:
   - This is enabled by default by apiserver
   - Type this URL in a browser or use `curl`
   - `curl -L http://[master-ip]:8080/api/v1/proxy/namespaces/[namespace]/services/[service-name][:[port-name]]`
   - You may build a proxy in front of this with `nginx` that forwards all requests to the apiserver proxy
 - Connect a computer to the `flannel` network
   - It's possible to start `flannel` and `kube-proxy` on another computer **in the same network** and access all services
   - Run these two commands from a `amd64` machine with docker:
     - `docker run --net=host -d --privileged -v /dev/net:/dev/net quay.io/coreos/flannel:0.5.5 /opt/bin/flanneld --etcd-endpoints=http://$MASTER_IP:4001`
     - `docker run --net=host -d --privileged gcr.io/google_containers/hyperkube-amd64:v1.2.0 /hyperkube proxy --master=http://$MASTER_IP:8080 --v=2`'
   - Replace $MASTER_IP with the actual ip of your master node
   - The consuming `amd64` computer can access all services
   - For example: `curl -k https://10.0.0.1`
 - Make a `service` with `externalIP`
   - Via `kubectl`: `kubectl expose rc {some rc} --port={the port this service will listen on} --container-port={the port the container exposes} --external-ip={the host you want to listen on}`  
   - Example: `kubectl expose rc my-nginx --port=9060 --container-port=80 --external-ip=192.168.200.100`
   - This will make the service accessible at `192.168.200.100:9060`
 - Service `NodePort`
   - If one sets Service `.spec.type` to `NodePort`, Kubernetes automatically exposes the service on a random port on every node

#### See node health via `cAdvisor`

Go to a web browser and type: `{IP of your node}:4194` and a nice dashboard will be there and show you some nice real-time stats.

## Configuration

There is a configuration file: `/etc/kubernetes/k8s.conf`, where you can customize some things:
 - `K8S_MASTER_IP`: Points to the master in the cluster. If the node is master, it uses `127.0.0.1` (aka `localhost`). Default: `127.0.0.1`
 - `FLANNEL_SUBNET`: The subnet `flannel` should use. [More information](https://github.com/coreos/flannel#configuration). Default: `10.1.0.0/16`
 - `FLANNEL_BACKEND`: The backend `flannel` will use to proxy packets from one node to another. [More information](https://github.com/coreos/flannel#configuration). Default: `host-gw`, which requires Layer 2 connectivity between nodes.
 - `DNS_IP`: The IP the DNS addon will allocate. Defaults to: `10.0.0.10`. Do not change this unless you have a good reason.
 - `DNS_DOMAIN`: The domain for DNS names. Defaults to: `cluster.local`. If you for example changes this to `abc`, your DNS names will look like this: `my-nginx.default.svc.abc`.
 - `DOCKER_STORAGE_DRIVER`: The storage driver all docker daemons will use. Note: You shouldn't change this after the installation.

**Note:** You must change the values in `k8s.conf` before starting Kubernetes. Otherwise they won't have effect, just be able to harm your setup. And remember that if you change `DNS_IP` and `DNS_DOMAIN` on one node, you'll have to change them on all nodes in the cluster


On Arch Linux, this file will override the default `eth0` settings. If you have a special `eth0` setup (or use some other network), edit this file to fit your use case: `/etc/systemd/network/dns.network`

## Docker versions

With release `v0.6.5` and higher, only `docker-1.10.0` and higher is supported.

## Cross-compiling

For this project, I compile the binaries on ARM hosts. But I've also made a script that can cross-compile if you want to compile it faster. [Check it out](scripts/build-k8s-on-amd64/Dockerfile)

## Running tests

Right now there is one test:
 - `run-test master` will simply do what the `Use Kubernetes` section does. It setups a master, runs `nginx`, starts the DNS, registry and sleep addons.

Logs can be found at: `/etc/kubernetes/source/scripts/logs`
The tests can be found at: `/etc/kubernetes/source/scripts/tests`
The test might fail, although the thing it's testing is in fact working. Report an issue in that case.

## Troubleshooting

If your cluster won't start, try `kube-config delete-data`. That will remove all data you store in `/var/lib/kubelet` and `/var/lib/kubernetes`. If you don't want to delete all data, but have to get Kubernetes up and running, you can answer `M`, when running `kube-config delete-data` and it will rename `/var/lib/kubernetes` and `/var/lib/kubelet` to `/var/lib/kubernetesold` and `/var/lib/kubeletold` so you may restore them later.

There is also no guarantee that the master/workers and all their services will come up successfully after a reboot, but it's possible.

## Contributing

I would be really glad to review your Pull Request! One thing would be good to remember though. I develop on the `dev` branch, so it would be great if you target that one instead of `master`

Thanks!

## Beta version

This project is under development.  
I develop things on the [`dev` branch](../../tree/dev)

[Changelog](CHANGELOG.md)

## Future work

See the [ROADMAP](ROADMAP.md)

## License

[MIT License](LICENSE)

## Goals for this project

This project ports [Kubernetes](https://github.com/kubernetes/kubernetes) to the ARM architecture. 
The primary boards used for testing is Raspberry Pi 2´s.

My goal for this project is that it should be as small as possible, while retaining its flexibility.  
It should also be as easy as possible for people, who don´t know anything about Kubernetes, to get started.

I also have opened a proposal for Kubernetes on ARM: [kubernetes/kubernetes#17981](https://github.com/kubernetes/kubernetes/issues/17981).  
The long-term goal most of this functionality should be present in core Kubernetes.

It should be easy in the future to add support for new boards and operating systems.

#### Feel free to create an issue if you find a bug or think that something should be added or removed!
