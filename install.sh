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



echo "This script will run for about 15 min, depending on how updated your system is"

echo "Hope you do this over ssh or by cmd, so you can copy the output"
df -h

echo "Updating the system..."
time pacman -Syu --noconfirm

echo "Now were going to install some packages"
time pacman -S docker git rsync nmap screen --noconfirm

# samba salt

echo "Now we can see how much those updates affected us."
df -h

echo "Set the timezone to Helsinki"
timedatectl set-timezone Europe/Helsinki

### SHOULD WE HAVE THIS ? ###

echo "Git is very good software. Were going to use it."
echo "We'll set up a bare repository with a live folder."

cd /
cd /lib

mkdir luxas
cd luxas

# Our live folder
mkdir master

# Our git repo
mkdir master.git
cd master.git

git init --bare

cd hooks
cat > post-receive <<EOF
#!/bin/bash
git --work-tree=/lib/luxas/master --git-dir=/lib/luxas/master.git checkout -f
EOF

chmod a+x post-receive

### /SHOULD WE HAVE THIS ? ###

echo "Docker needs configuration. Let's do it."
systemctl enable docker

sed -e 's@/usr/bin/docker -d@/usr/bin/docker -d -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 -s overlay@' -i /usr/lib/systemd/system/docker.service

echo "Make an 1GB swapfile"
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
Before=salt-minion.service
[Service]
Type=oneshot
ExecStart=/usr/local/bin/sethostname.sh
[Install]
WantedBy=multi-user.target
EOF

systemctl enable sethostname.service


echo "Setup an user account"
useradd --create-home --shell /bin/bash -g users pi
echo "pi:raspberry" | chpasswd

