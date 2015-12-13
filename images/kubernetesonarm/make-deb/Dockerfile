FROM luxas/raspbian

ENV PACKAGE_NAME=kubernetes-on-arm		\
	PACKAGE_REVISION=-1					\
	PACKAGE_ARCH=armhf					\
	PACKAGE_GIT_TAG=v0.6.0
# package git tag may also be "master"

COPY makedeb.sh /

# Install packages and download the repo
RUN apt-get update && apt-get install -y git fakeroot	&& \
	git clone -b $PACKAGE_GIT_TAG https://github.com/luxas/kubernetes-on-arm

RUN /makedeb.sh