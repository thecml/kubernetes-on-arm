FROM luxas/raspbian

ENV PACKAGE_NAME=kubernetes-on-arm		\
	PACKAGE_REVISION=-2					\
	PACKAGE_ARCH=armhf					\
	PACKAGE_GIT_COMMIT=v0.6.2
# PACKAGE_GIT_COMMIT may be a branch like master or dev, a commit hash or a tag

# Install packages and download the repo
RUN apt-get update && apt-get install -y git fakeroot	&& \
	git clone https://github.com/luxas/kubernetes-on-arm && \
	cd kubernetes-on-arm && \
	git checkout $PACKAGE_GIT_COMMIT

COPY makedeb.sh /

RUN /makedeb.sh