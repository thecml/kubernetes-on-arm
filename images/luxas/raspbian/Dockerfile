FROM resin/rpi-raspbian

COPY apt-install /usr/bin/

ENV DEBIAN_FRONTEND=noninteractive

# Backup English, not sure if necessary, but anyway
# Then remove unused stuff, huge space savings
RUN cp -r /usr/share/locale/en_GB /tmp && \
	rm -rf /usr/share/man/?? /usr/share/man/??_* /usr/share/doc/* /usr/share/locale/* && \
	mv /tmp/en_GB /usr/share/locale/en_GB && \
	sudo apt-get autoremove
	chmod +x /usr/bin/apt-install && \
	sync && \
	apt-install nano curl
# Nano and curl is good to have

CMD ["/bin/bash"]
