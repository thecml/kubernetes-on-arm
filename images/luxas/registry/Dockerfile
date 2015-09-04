FROM luxas/raspbian

# Install (required?) packages that are required and present
RUN apt-install ca-certificates librados2 apache2-utils

# Copy the binary and the config file
COPY _bin/registry /bin/registry
COPY config.yml /etc/docker/registry/config.yml

# Flag that this dir should be stored on the host
VOLUME ["/var/lib/registry"]

# This port should be open
EXPOSE 5000

# Start the registry on start
ENTRYPOINT ["/bin/registry"]

# ...with it's config file
CMD ["/etc/docker/registry/config.yml"]