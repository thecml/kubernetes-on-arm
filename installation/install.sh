#!/bin/bash

# This script is going to set up lucas amazing Raspberry Pi cloud service!
# First, install packages
# Then, set up git for code changes
#
#
#
#
#
#
#
#
#


trap 'exit' ERR



echo "This script will run for about 3 min, depending on how updated your system is"

echo "Hope you do this over ssh or by cmd, so you can copy the output"
df -h

echo "Updating the system..."
time pacman -Syu --noconfirm

echo "Now were going to install some packages"
time pacman -S docker git make --noconfirm

# for now, not necessary: rsync nmap screen
# not needed now: samba salt

echo "Now we can see how much those updates affected us."
df -h

echo "Set the timezone to Helsinki"
timedatectl set-timezone Europe/Helsinki

### SHOULD WE HAVE THIS ? ###

echo "We'll set up a bare git repository with a live folder."

# Make our folders for git versioning
mkdir /lib/luxas /lib/luxas/luxcloud /lib/luxas/luxcloud.git

# Move to our bare repo
cd /lib/luxas/luxcloud.git

# Make version control
git init --bare

cd hooks
cat > post-receive <<EOF
#!/bin/bash
git --work-tree=/lib/luxas/luxcloud --git-dir=/lib/luxas/luxcloud.git checkout -f
find /lib/luxas/luxcloud -name "*.sh" -exec chmod +x {} \;
chmod +x /lib/luxas/luxcloud/utils/strip-image/*
EOF

chmod a+x post-receive

### /SHOULD WE HAVE THIS ? ###

echo "Docker needs configuration. Let's do it."

## SYSTEM DOCKER ##

cat > /etc/systemd/system/system-docker.socket <<EOF
[Unit]
Description=Docker Socket for the API
PartOf=system-docker.service

[Socket]
ListenStream=/var/run/system-docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

cat > /etc/systemd/system/system-docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
After=network.target system-docker.socket
Requires=system-docker.socket

[Service]
ExecStart=/usr/bin/docker -d -H unix:///var/run/system-docker.sock -s overlay -p /var/run/system-docker.pid --iptables=false --ip-masq=false --bridge=none --graph=/var/lib/system-docker
MountFlags=slave
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

cat >> /root/.bashrc <<EOF
system-docker(){
	docker -H unix:///var/run/system-docker.sock $@
}


EOF



sed -e 's@/usr/bin/docker -d@/usr/bin/docker -d -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 -s overlay@' -i /usr/lib/systemd/system/docker.service
sed -e 's@After=network.target docker.socket@After=network.target docker.socket system-docker.service@' -i /usr/lib/systemd/system/docker.service

systemctl enable system-docker
systemctl enable docker

## SWAPFILE, REQUIRED WHEN COMPILING ##

echo "Make an 1GB swapfile, NOTE: it takes up sd card space"
dd if=/dev/zero of=/swapfile bs=1M count=1024
mkswap /swapfile
chmod 600 /swapfile
swapon /swapfile

cat >> /etc/fstab <<EOF
/swapfile  none  swap  defaults  0  0
EOF


echo "Make custom startup file"
cat > /usr/local/bin/sethostname.sh <<EOF
#!/bin/sh
hostnamectl set-hostname $(tr -d ':' < /sys/class/net/eth0/address)
timedatectl set-timezone Europe/Helsinki
EOF

chmod 755 /usr/local/bin/sethostname.sh

cat > /etc/systemd/system/sethostname.service <<EOF
[Unit]
Description=Set hostname to MAC address
[Service]
Type=oneshot
ExecStart=/usr/local/bin/sethostname.sh
[Install]
WantedBy=multi-user.target
EOF

systemctl enable sethostname


echo "Setup an user account"
useradd --create-home --shell /bin/bash -g users -G docker pi
echo "pi:raspberry" | chpasswd

reboot