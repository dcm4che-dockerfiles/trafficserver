#!/bin/bash

set -e

if [ "$1" = 'traffic_cop' ]; then
    if [ ! -d $ATS_HOME/etc ]; then
        cp -r /docker-entrypoint.d/etc $ATS_HOME
        chown -R tserver:tserver $ATS_HOME/etc
    fi
fi

exec "$@"
