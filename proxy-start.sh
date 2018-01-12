#!/bin/bash

set -e
set -x

if [ ! -f /etc/ssl/dhparam.pem ]
then
    # NOTE: we only need this if we want to support non-PFS ciphers
    openssl dhparam -out /etc/ssl/dhparam.pem 2048
fi

if [ ! -f /etc/ssl/ssl_certificate -o ! -f /etc/ssl/ssl_certificate_key ]
then
    openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/ssl_certificate_key -out /etc/ssl/ssl_certificate -days 365 -nodes -subj '/CN=localhost' -sha256
fi

echo resolver $(awk 'BEGIN{ORS=" "} $1=="nameserver" {print $2}' /etc/resolv.conf) ";" > /etc/nginx/resolvers.conf

# Enable dh_plugin configuration only if dh_plugin resolvable
getent hosts dh_plugin \
  && ln -s /etc/nginx/upstreams-available/plugin_upstream.conf /etc/nginx/upstream.d/plugin_upstream.conf \
  && ln -s /etc/nginx/locations-available/plugin_location.conf /etc/nginx/location.d/plugin_location.conf

# Enable wsproxyext configuration only if wsproxyext resolvable
getent hosts wsproxyext \
  && ln -s /etc/nginx/upstreams-available/wsproxyext.conf /etc/nginx/upstream.d/wsproxyext.conf \
  && ln -s /etc/nginx/locations-available/wsproxyext.conf /etc/nginx/location.d/wsproxyext.conf

nginx
