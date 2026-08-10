FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-xml \
    php-mbstring \
    php-zip \
    curl \
    mariadb-client \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# WP-CLI: the tool we use to install/configure WordPress non-interactively
RUN curl -o /usr/local/bin/wp -sSL \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# php-fpm needs to listen on a TCP port (or a socket in a shared volume)
# so nginx, in its own container, can reach it. We use a custom pool conf.
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup_wp.sh /usr/local/bin/setup_wp.sh
RUN chmod +x /usr/local/bin/setup_wp.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup_wp.sh"]
