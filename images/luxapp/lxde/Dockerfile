FROM luxas/raspbian

ENV DEBIAN_FRONTEND=noninteractive \
	HOME=/home/pi


RUN apt-install --force-yes --no-install-recommends \
        supervisor \
        sudo \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine \
        chromium \
        xrdp

EXPOSE 3389

COPY supervisord.conf startup.sh /

RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo pi && \
	echo "pi:raspberry" | chpasswd && \
	mkdir /var/run/sshd && \
	mkdir /root/.vnc

WORKDIR /home/pi

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/supervisord.conf"]