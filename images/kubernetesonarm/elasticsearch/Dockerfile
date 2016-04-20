FROM larmog/armhf-alpine-java:jdk-8u73

COPY version.sh /

# Install Elasticsearch.
RUN chmod +x /version.sh \
    && . /version.sh \ 
    && apk add --update curl ca-certificates sudo \
  	&& curl -sSL https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${ELASTICSEARCH_VERSION}/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz | tar -xz \
  	&& mv /elasticsearch-${ELASTICSEARCH_VERSION} /elasticsearch \
  	&& rm -rf $(find /elasticsearch | egrep "(\.(exe|bat)$|sigar/.*(dll|winnt|x86-linux|solaris|ia64|freebsd|macosx))") \
  	&& apk del curl

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

CMD ["/run.sh"]
