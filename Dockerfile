FROM debian:jessie

ENV TS_VERSION=6.2.0

# explicitly set user/group IDs
RUN groupadd -r tserver --gid=1030 && useradd -r -g tserver --uid=1030 tserver

RUN set -ex \
 && apt-get update \
 && apt-get -y install gcc bzip2 libc6-dev linux-libc-dev make curl libncursesw5-dev libssl-dev zlib1g-dev libpcre3-dev \
      perl libxml2-dev libcap-dev tcl8.6-dev libhwloc-dev libgeoip-dev libmysqlclient-dev libkyotocabinet-dev libreadline-dev \
 && apt-get clean \
 && cd /usr/src \
 && curl -L http://www-eu.apache.org/dist/trafficserver/trafficserver-${TS_VERSION}.tar.bz2 | tar xj \
 && cd trafficserver-${TS_VERSION} \
 && ./configure --prefix=/opt/ats --with-user=tserver && make && make install \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/src/trafficserver-${TS_VERSION}

CMD ["/opt/ats/bin/trafficserver", "start"]
