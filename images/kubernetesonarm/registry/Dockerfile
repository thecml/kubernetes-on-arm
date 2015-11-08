FROM luxas/alpine

# Install packages
# RUN apk-install ca-certificates

# Copy the binary and the config file
COPY registry /
COPY config.yml /etc/docker/registry/config.yml

# Flag that this dir should be stored on the host
#VOLUME ["/var/lib/registry"]

# This port should be open
#EXPOSE 5000

# Start the registry...
ENTRYPOINT ["/registry"]

# ...with it's config file
CMD ["/etc/docker/registry/config.yml"]