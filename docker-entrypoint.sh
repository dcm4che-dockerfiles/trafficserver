#!/bin/bash

set -e

if [ "$1" = 'traffic_cop' ]; then
    if [ ! -f $TS_HOME/etc/trafficserver/records.config ]; then
        cp -r /docker-entrypoint.d/etc $TS_HOME
        chown -R tserver:tserver $TS_HOME/etc
        cat >> $TS_HOME/etc/trafficserver/records.config << EOF
CONFIG proxy.config.hostdb.host_file.path STRING /etc/hosts
CONFIG proxy.config.http.cache.ignore_client_no_cache INT 0
CONFIG proxy.config.http.cache.required_headers INT 0
CONFIG proxy.config.http_ui_enabled INT 1
EOF
        cat >> $TS_HOME/etc/trafficserver/remap.config << EOF
map ${TS_MAP_TARGET}/myCI http://{cache}
map ${TS_MAP_TARGET} ${TS_MAP_REPLACEMENT}
reverse_map ${TS_MAP_REPLACEMENT} ${TS_MAP_TARGET}
EOF
        cat >> $TS_HOME/etc/trafficserver/cache.config << EOF
url_regex=${TS_MAP_TARGET}/auth/.* never-cache
url_regex=${TS_MAP_TARGET}/dcm4chee-arc/ui/.* never-cache
EOF
        sed -i "s%var/trafficserver 256M%${TS_STORAGE}%" $TS_HOME/etc/trafficserver/storage.config
    fi
    if [ ! -d $TS_HOME/var/log/trafficserver ]; then
        mkdir -p $TS_HOME/var/trafficserver $TS_HOME/var/log/trafficserver
        chown -R tserver:tserver $TS_HOME/var
    fi
fi

exec "$@"
