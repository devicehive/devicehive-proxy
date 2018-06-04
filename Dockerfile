FROM nginx:1.14.0

ENV DH_PROXY_VERSION="3.5.0"

LABEL org.label-schema.url="https://devicehive.com" \
      org.label-schema.vendor="DeviceHive" \
      org.label-schema.vcs-url="https://github.com/devicehive/devicehive-proxy" \
      org.label-schema.name="devicehive-proxy" \
      org.label-schema.version="$DH_PROXY_VERSION"

ADD nginx.conf /etc/nginx/nginx.conf

ADD upstream.d/ /etc/nginx/upstream.d/
ADD location.d/ /etc/nginx/location.d/
ADD server-available/ /etc/nginx/server-available/
ADD upstreams-available/ /etc/nginx/upstreams-available/
ADD locations-available/ /etc/nginx/locations-available/

ADD admin/ /opt/devicehive/admin/

RUN mkdir /etc/nginx/stream.d/ /etc/nginx/server.d/

COPY proxy-start.sh /opt/devicehive/

WORKDIR /opt/devicehive/

EXPOSE 8080 8443

ENTRYPOINT ["/bin/sh"]

CMD ["./proxy-start.sh"]
