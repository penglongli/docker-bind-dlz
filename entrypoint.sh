#!/bin/bash

# init named.conf ${MYSQL_DATA_SOURCE}
envsubst < /etc/named/named.conf > /etc/named/named.conf

exec "$@";
