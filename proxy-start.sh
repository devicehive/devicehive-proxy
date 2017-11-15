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

echo resolver $(aws 'BEGIN{ORS=" "} $1=="nameserver" {print $2}' /etc/resolv.conf) ";" > /etc/nginx/resolvers.conf

nginx
