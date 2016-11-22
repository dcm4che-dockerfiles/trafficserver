#!/bin/bash

set -e

if [ "$1" = 'traffic_cop' ]; then
    if [ ! -f $TS_HOME/etc/trafficserver/records.config ]; then
        cp -rp /docker-entrypoint.d/etc $TS_HOME
        cat >> $TS_HOME/etc/trafficserver/records.config << EOF
CONFIG proxy.config.hostdb.host_file.path STRING /etc/hosts
CONFIG proxy.config.http.cache.ignore_client_no_cache INT 0
CONFIG proxy.config.http.cache.when_to_revalidate INT ${TS_WHEN_TO_REVALIDATE}
CONFIG proxy.config.http.cache.required_headers INT 1
CONFIG proxy.config.http_ui_enabled INT 1
EOF
        cat >> $TS_HOME/etc/trafficserver/remap.config << EOF
map ${TS_MAP_TARGET}/myCI http://{cache}
map ${TS_MAP_TARGET} ${TS_MAP_REPLACEMENT} @plugin=cachekey.so @pparam=--include-headers=Accept
reverse_map ${TS_MAP_REPLACEMENT} ${TS_MAP_TARGET}
EOF
        sed -i "s%var/trafficserver 256M%${TS_STORAGE}%" $TS_HOME/etc/trafficserver/storage.config
    fi
    if [ ! -f $TS_HOME/var/trafficserver/hostdb.config ]; then
        mkdir -p $TS_HOME/var/trafficserver
        chown tserver:tserver $TS_HOME/var/trafficserver
    fi
    if [ ! -f $TS_HOME/var/log/trafficserver/manager.log ]; then
        mkdir -p $TS_HOME/var/log/trafficserver
        chown tserver:tserver $TS_HOME/var/log/trafficserver
    fi
fi

exec "$@"
