#!/bin/bash

BIND_SYSDIR=/etc/named

# init named.conf ${MYSQL_DATA_SOURCE}
envsubst '${MYSQL_DATA_SOURCE}' < /etc/named/named.conf.template > /etc/named/named.conf

# with bind_exporter
if [ ${ENABLE_EXPORTER} ]; then
    sed -i '/#statistics/r /statistics.conf' ${BIND_SYSDIR}/named.conf
fi

exec "$@";
