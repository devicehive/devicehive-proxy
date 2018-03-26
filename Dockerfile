FROM nginx:1.13.9

ENV DH_PROXY_VERSION="3.4.5-next"

LABEL org.label-schema.url="https://devicehive.com" \
      org.label-schema.vendor="DeviceHive" \
      org.label-schema.vcs-url="https://github.com/devicehive/devicehive-proxy" \
      org.label-schema.name="devicehive-proxy" \
      org.label-schema.version="$DH_PROXY_VERSION"

RUN apt-get update && \
  apt-get install -y openssl && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/nginx/location.d
ADD nginx.conf /etc/nginx/nginx.conf

ADD upstream.d/ /etc/nginx/upstream.d/
ADD location.d/ /etc/nginx/location.d/
ADD upstreams-available/ /etc/nginx/upstreams-available/
ADD locations-available/ /etc/nginx/locations-available/

ADD admin/ /opt/devicehive/admin/

RUN mkdir /etc/nginx/stream.d/

COPY proxy-start.sh /opt/devicehive/

WORKDIR /opt/devicehive/

EXPOSE 8080 8443

ENTRYPOINT ["/bin/sh"]

CMD ["./proxy-start.sh"]
