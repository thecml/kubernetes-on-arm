FROM hypriot/rpi-alpine-scratch

# Set environment
ENV JAVA_VERSION=8 \
    JAVA_UPDATE=73 \
    JAVA_BUILD=02 \
    JAVA_HOME=/opt/jdk \
    PATH=$PATH:${PATH}:/opt/jdk/bin

COPY glibc/lib /lib
COPY glibc/etc/nsswitch.conf /etc/nsswitch.conf

# Download and install glibc
RUN apk --update add bash curl ca-certificates && \
  curl -sSL -H "Cookie: oraclelicense=accept-securebackup-cookie;" http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-arm32-vfp-hflt.tar.gz | tar -xz
  mkdir /opt && \
  mv jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE} /opt/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD} && \
  ln -s /opt/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD} /opt/jdk && \
  ln -s /opt/jdk/jre/bin/java /usr/bin/java && \
  rm -f glibc-*.apk jdk*.tar.gz /opt/jdk/src.zip && \
  rm -rf $JAVA_HOME/jre/bin/jjs \
       $JAVA_HOME/jre/bin/keytool \
       $JAVA_HOME/jre/bin/orbd \
       $JAVA_HOME/jre/bin/pack200 \
       $JAVA_HOME/jre/bin/policytool \
       $JAVA_HOME/jre/bin/rmid \
       $JAVA_HOME/jre/bin/rmiregistry \
       $JAVA_HOME/jre/bin/servertool \
       $JAVA_HOME/jre/bin/tnameserv \
       $JAVA_HOME/jre/bin/unpack200 && \
  apk del curl && \
  rm -rf /var/cache/apk/*
