FROM resin/rpi-raspbian

# Backup English, not sure if necessary, but anyway
# Then remove unused stuff, huge space savings
# This seems to make no difference if we aren't building from source but that can wait
RUN cp -r /usr/share/locale/en_GB /tmp && \
	rm -rf /usr/share/man/?? /usr/share/man/??_* /usr/share/doc/* /usr/share/locale/* && \
	mv /tmp/en_GB /usr/share/locale/en_GB


COPY apt-install /usr/bin/

RUN chmod +x /usr/bin/apt-install