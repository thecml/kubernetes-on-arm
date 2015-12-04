FROM luxas/raspbian

ENV PACKAGE_NAME=kubernetes-on-arm		\
	PACKAGE_REVISION=-1					\
	PACKAGE_ARCH=armhf					

COPY makedeb.sh /

# Install packages and download the repo
RUN apt-get update && apt-get install -y git fakeroot		&& \
	git clone https://github.com/luxas/kubernetes-on-arm

RUN /makedeb.sh