cat > /usr/lib/systemd/system/minion-k8s.service <<EOF
[Unit]
Description=The Minion Components for Kubernetes
After=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill minion-k8s minion-k8s-proxy
ExecStartPre=-/usr/bin/docker rm minion-k8s minion-k8s-proxy
ExecStart=/usr/bin/docker run --name=minion-k8s --net=host -v /var/run/docker.sock:/var/run/docker.sock  k8s/hyperkube /hyperkube kubelet --pod_infra_container_image="k8s/pause" --api-servers=http://${MASTER_IP}:8080 --v=2 --address=127.0.0.1 --enable-server --hostname-override=$(/usr/bin/hostname -i | /usr/bin/awk '{print $1}')
ExecStartPost=/usr/bin/docker run --name=minion-k8s-proxy --net=host --privileged k8s/hyperkube /hyperkube proxy --master=http://${MASTER_IP}:8080 --v=2
ExecStop=/usr/bin/docker stop minion-k8s minion-k8s-proxy

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/docker.service.d/luxcloud.conf <<EOF
[Unit]
After=system-docker.service flannel.service

[Service]
EnvironmentFile=/var/lib/flannel/subnet.env
ExecStart=
ExecStart=/usr/bin/docker -d -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 -s overlay --bip=$FLANNEL_SUBNET --mtu=$FLANNEL_MTU
EOF