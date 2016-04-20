FROM larmog/armhf-alpine-java:jdk-8u73

ENV VERSION 2.2.1

# Install Elasticsearch.
RUN apk add --update curl ca-certificates sudo && \
  curl -sSL https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/$VERSION/elasticsearch-$VERSION.tar.gz | tar -zx && \
  mv /elasticsearch-$VERSION /elasticsearch && \
  rm -rf $(find /elasticsearch | egrep "(\.(exe|bat)$|sigar/.*(dll|winnt|x86-linux|solaris|ia64|freebsd|macosx))") && \
  apk del curl

# Copy configuration
COPY config/logging.yml /elasticsearch/config

# Add configuration for plugin install
COPY config/es-plugin-install.yml /elasticsearch/config/elasticsearch.yml

# Install
RUN /elasticsearch/bin/plugin install io.fabric8/elasticsearch-cloud-kubernetes/2.2.1_01 --verbose

# Add config
COPY config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Copy run script
COPY run.sh /

RUN chmod a+x /run.sh

CMD ["/run.sh"]
