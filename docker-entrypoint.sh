#!/bin/bash

set -e

if [ "$1" = 'traffic_cop' ]; then
    if [ ! -f $ATS_HOME/etc/trafficserver/records.config ]; then
        cp -r /docker-entrypoint.d/etc $ATS_HOME
        chown -R tserver:tserver $ATS_HOME/etc
    fi
    if [ ! -d $ATS_HOME/var/log/trafficserver ]; then
        mkdir -p $ATS_HOME/var/trafficserver $ATS_HOME/var/log/trafficserver
        chown -R tserver:tserver $ATS_HOME/var
    fi
fi

exec "$@"
