FROM resin/rpi-raspbian:jessie

# Install certificates
RUN apt-get update && apt-get install -y -q \
        ca-certificates \
        && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# Copy the binary and the config file
COPY registry /
COPY config.yml /etc/docker/registry/config.yml

# Start the registry...
ENTRYPOINT ["/registry"]

# ...with it's config file
CMD ["serve", "/etc/docker/registry/config.yml"]