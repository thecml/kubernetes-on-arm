FROM luxas/archlinux

RUN pacman -Syu --noconfirm && \
	pacman -S tar docker && \
	chmod 0755 /lib/*

VOLUME ["/var/run/docker.sock"]