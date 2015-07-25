# We do not need any recommendations
cat > /etc/apt/apt.conf <<EOF
	APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;
EOF

# Install apt-install
chmod +x /usr/bin/apt-install

# Fix bug
#sync

# And run
#apt-install wget git