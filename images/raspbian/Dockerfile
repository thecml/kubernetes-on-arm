FROM resin/rpi-raspbian

COPY apt-install /usr/bin/
COPY inbuild.sh /

RUN /inbuild.sh && rm /inbuild.sh