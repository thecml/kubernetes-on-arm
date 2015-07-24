cat > /etc/apt/apt.conf <<EOF
	APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;
EOF

rm -rf /usr/share/man/?? /usr/share/man/??_*

# Huge space savings
cp /usr/share/locale/en_GB /tmp
rm -rf /usr/share/locale/*
mv /tmp/en_GB /usr/share/locale/en_GB

rm -rf /usr/share/doc/*

chmod +x apt-install

apt-install wget git