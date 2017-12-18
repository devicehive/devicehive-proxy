FROM nginx:1.13.7

ENV DH_PROXY_VERSION="3.4.2-next"

LABEL org.label-schema.url="https://devicehive.com" \
      org.label-schema.vendor="DeviceHive" \
      org.label-schema.vcs-url="https://github.com/devicehive/devicehive-proxy" \
      org.label-schema.name="devicehive-proxy" \
      org.label-schema.version="$DH_PROXY_VERSION"

RUN mkdir /etc/nginx/location.d
ADD nginx.conf /etc/nginx/nginx.conf

# Add admin console
RUN apt-get update && \
  apt-get install -y curl && \
  mkdir -p /opt/devicehive/admin && \
  cd /opt/devicehive/admin && \
  curl -L "https://github.com/devicehive/devicehive-admin-console/archive/3.4.0.tar.gz" | tar -zxf - --strip-components=1 && \
  apt-get clean

ADD upstream.d/ /etc/nginx/upstream.d/
ADD location.d/ /etc/nginx/location.d/
ADD upstreams-available/ /etc/nginx/upstreams-available/
ADD locations-available/ /etc/nginx/locations-available/

RUN mkdir /etc/nginx/stream.d/

COPY proxy-start.sh /opt/devicehive/

WORKDIR /opt/devicehive/

EXPOSE 8080 8443

ENTRYPOINT ["/bin/sh"]

CMD ["./proxy-start.sh"]
