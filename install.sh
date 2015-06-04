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
#


echo "Hope you do this over ssh or by cmd, so you can copy the output"
df -h

echo "Updating the system..."
time pacman -Syu --noconfirm

echo "Now were going to install some packages"
time pacman -S docker git samba rsync nmap fdisk --noconfirm

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
cat > post-recieve <<EOF
#!/bin/bash
git --work-tree=/lib/luxas/master --git-dir=/lib/luxas/master.git checkout -f
EOF

