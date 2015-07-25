mkdir pre
cd pre

cat > Dockerfile <<EOF
FROM luxas/buildbian

RUN cd / && \
	git clone https://go.googlesource.com/go && \
	cd go && \
	git checkout go1.4.1 && \
	src/make.bash

CMD["/bin/echo", "Built"]
EOF

docker build -t luxas/build-go .

CID=$(docker run luxas/build-go)

docker cp $(CID):/go/bin/* ../

docker rm $(CID)
docker rmi luxas/build-go

cd ..
rm -r pre