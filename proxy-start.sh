#!/bin/bash

set -e
set -x

if [ -f /etc/ssl/dhparam.pem -a -f /etc/ssl/ssl_certificate -a -f /etc/ssl/ssl_certificate_key ]
then
  echo "Found TLS certificate and key. Enabling TLS in nginx."
  ln -sf /etc/nginx/server-available/ssl-parameters.conf /etc/nginx/server.d/
else
  echo "TLS certificate, key or DH parameters file not found. Starting nginx without TLS support."
fi

echo resolver $(awk 'BEGIN{ORS=" "} $1=="nameserver" {print $2}' /etc/resolv.conf) ";" > /etc/nginx/resolvers.conf

# Enable dh_plugin configuration only if dh_plugin resolvable
getent hosts dh_plugin \
  && ln -sf /etc/nginx/upstreams-available/plugin_upstream.conf /etc/nginx/upstream.d/ \
  && ln -sf /etc/nginx/locations-available/plugin_location.conf /etc/nginx/location.d/

# Enable wsproxyext configuration only if wsproxyext resolvable
getent hosts wsproxyext \
  && ln -sf /etc/nginx/upstreams-available/wsproxyext.conf /etc/nginx/upstream.d/ \
  && ln -sf /etc/nginx/locations-available/wsproxyext.conf /etc/nginx/location.d/

nginx
