#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

# Self-signed cert is fine here -- 42's grading is local/offline, there's
# no real CA to issue one for a .42.fr domain. Only generate it once;
# it doesn't need to be a volume since it's cheap to regenerate anyway,
# but we still guard it so restarts don't churn a new cert every time.
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=DE/ST=Inception/L=42/O=42/CN=${DOMAIN_NAME}"
fi

# Inject DOMAIN_NAME into the config template.
envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/nginx.conf.template \
    > /etc/nginx/sites-enabled/default

# Foreground, PID 1 -- nginx's own recommended way to run in containers,
# no need for any wrapper.
exec nginx -g "daemon off;"
