mkdir prebuild

cd prebuild

mkdir bin

cat > Dockerfile <<EOF
FROM resin/rpi-raspbian
RUN sudo apt-get update 
RUN sudo apt-get install wget -y
RUN cd /tmp && wget http://node-arm.herokuapp.com/node_latest_armhf.deb && dpkg -i node_latest_armhf.deb
EOF

docker build -t luxas/mininode-pre .

docker run --name=mininode-bin luxas/mininode-pre /bin/echo "Successfully built"


docker cp mininode-bin:/usr/local/bin/node bin
docker cp mininode-bin:/usr/local/lib/node_modules bin

docker rm mininode-bin
docker rmi luxas/mininode-pre