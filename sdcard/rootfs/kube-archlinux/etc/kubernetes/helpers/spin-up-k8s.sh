#!/bin/bash
# This is a helper file for systemd
# The systemd script isn't able to get the ip of the machine dynamically, so we do it here instead
 



if [[ $1 == "master" ]]; then
	exec docker run --name=k8s-master --net=host -v /var/run/docker.sock:/var/run/docker.sock k8s/hyperkube /hyperkube kubelet --pod_infra_container_image="k8s/pause" --api-servers=http://localhost:8080 --v=2 --address=0.0.0.0 --enable-server --hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}') --config=/etc/kubernetes/manifests-multi
else
	source /etc/kubernetes/k8s.conf
	exec docker run --name=k8s-minion --net=host -v /var/run/docker.sock:/var/run/docker.sock  k8s/hyperkube /hyperkube kubelet --pod_infra_container_image="k8s/pause" --api-servers=http://${K8S_MASTER_IP}:8080 --v=2 --address=127.0.0.1 --enable-server --hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}')
fi