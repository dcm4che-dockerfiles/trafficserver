FROM debian:buster

ENV TS_VERSION=8.0.6 \
    TS_HOME=/opt/ats

# explicitly set user/group IDs
RUN groupadd -r tserver --gid=1030 && useradd -r -g tserver --uid=1030 tserver

RUN set -ex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        locales \
        build-essential \
        bzip2 \
        libssl-dev \
        libxml2 \
        libxml2-dev \
        libpcre3 \
        libpcre3-dev \
        tcl \
        tcl-dev \
        libboost-dev \
 && cd /usr/src \
 && curl -L http://www-eu.apache.org/dist/trafficserver/trafficserver-${TS_VERSION}.tar.bz2 | tar xj \
 && cd trafficserver-${TS_VERSION} \
 && ./configure --prefix=${TS_HOME} --with-user=tserver --enable-experimental-plugins --disable-hwloc \
 && make \
 && make install \
 && make distclean \
 && apt-get purge --auto-remove -y \
        curl \
        build-essential \
        bzip2 \
        libssl-dev \
        libxml2-dev \
        libpcre3-dev \
        tcl-dev \
        libboost-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/src/trafficserver-${TS_VERSION} \
 && mkdir /docker-entrypoint.d \
 && mv $TS_HOME/etc /docker-entrypoint.d

# Default configuration: can be overridden at the docker command line
ENV TS_MAP_TARGET=http://localhost:8080 \
    TS_MAP_REPLACEMENT=http://dcm4chee-arc:8080 \
    TS_STORAGE="var/trafficserver 256M" \
    TS_WHEN_TO_REVALIDATE=2

ENV PATH $TS_HOME/bin:$PATH

VOLUME $TS_HOME/var

# Expose the ports we're interested in
EXPOSE 8080

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["traffic_server"]
