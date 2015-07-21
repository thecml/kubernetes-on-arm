FROM luxas/nodejs

VOLUME ["/usr/lib/web"]
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY inbuild.sh /inbuild.sh

RUN /bin/sh /inbuild.sh

WORKDIR ["/usr/lib/web"]
CMD ["/usr/bin/supervisord"]