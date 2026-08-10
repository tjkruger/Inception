FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf.template /etc/nginx/templates/nginx.conf.template

COPY tools/setup_nginx.sh /usr/local/bin/setup_nginx.sh
RUN chmod +x /usr/local/bin/setup_nginx.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/setup_nginx.sh"]
