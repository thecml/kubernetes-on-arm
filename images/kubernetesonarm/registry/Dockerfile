FROM luxas/alpine

# Copy the binary and the config file
COPY registry /
COPY config.yml /etc/docker/registry/config.yml

# Start the registry...
ENTRYPOINT ["/registry"]

# ...with it's config file
CMD ["/etc/docker/registry/config.yml"]
