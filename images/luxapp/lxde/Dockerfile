FROM luxas/raspbian

ENV DEBIAN_FRONTEND=noninteractive \
	HOME=/home/pi


RUN apt-install \
        supervisor \
        sudo \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine \
        xrdp

EXPOSE 3389

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo pi && \
	echo "pi:raspberry" | chpasswd && \
	mkdir /var/run/sshd && \
	mkdir /home/pi/.vnc

WORKDIR /home/pi

CMD ["/usr/bin/supervisord","-n"]