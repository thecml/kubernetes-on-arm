#Install compilation tools
pacman -S gcc make patch git --noconfirm

cd /

#Download go
git clone https://go.googlesource.com/go
cd go

#Use go 1.4 and build
git checkout go1.4.1

cd src
./make.bash

#Now were on /
cd /

# Copy the go binary to the $PATH
cp /go/bin/go /usr/bin

# Remove the go source
rm -r /go

# Make the gopath
cat >> /etc/profile <<EOF

GOPATH="/usr/gopath"
export GOPATH
EOF

#Now we have go in our path