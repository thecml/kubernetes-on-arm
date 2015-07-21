# Make a folder for the web content
mkdir /usr/lib/web
cd /usr/lib/web

# Install web tools
npm install -g bower http-server

# Do so we can run two processes at the same time, and then clean
apt-get update
apt-get install supervisor -y
apt-get autoclean
apt-get autoremove
rm -r /var/cache/apt/* /var/lib/apt/lists/*