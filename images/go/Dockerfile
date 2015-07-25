FROM luxas/archlinux

COPY inbuild.sh /inbuild.sh
COPY go gofmt /usr/bin

RUN ./inbuild.sh && rm /inbuild.sh



#linux-raspberrypi-headers upx