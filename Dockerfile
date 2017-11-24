FROM nginx:1.13.7

RUN mkdir /etc/nginx/location.d
ADD nginx.conf /etc/nginx/nginx.conf

# Add admin console
RUN apt-get update && \
  apt-get install -y curl && \
  mkdir -p /opt/devicehive/admin && \
  cd /opt/devicehive/admin && \
  curl -L "https://github.com/devicehive/devicehive-admin-console/archive/development.tar.gz" | tar -zxf - --strip-components=1 && \
  apt-get clean

ADD upstream.d/ /etc/nginx/upstream.d/
ADD location.d/ /etc/nginx/location.d/

COPY proxy-start.sh /opt/devicehive/

WORKDIR /opt/devicehive/

EXPOSE 8080 8443

ENTRYPOINT ["/bin/sh"]

CMD ["./proxy-start.sh"]
