#Install compilation tools
pacman -S gcc make patch git --noconfirm

# Make the gopath
cat >> /etc/profile <<EOF

GOPATH="/usr/gopath"
export GOPATH
EOF

#Now we have go in our path
mkdir /usr/gopath