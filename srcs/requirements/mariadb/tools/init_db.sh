#!/bin/bash
set -e

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Volume is empty on first boot -> initialize. On later boots this dir
# already has data (persisted in the named volume), so we skip straight
# to starting mysqld.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    chown -R mysql:mysql /var/lib/mysql
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Start mysqld in the background, WITHOUT networking, just so we can
    # run setup SQL against it locally. This is a temporary bootstrap
    # instance, not the real long-running server.
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    TMP_PID=$!

    until mysqladmin ping --silent 2>/dev/null; do
        sleep 1
    done

    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$TMP_PID"
fi

# Real server, foreground, PID 1. No wrapper daemon, no supervisor script.
exec mysqld --user=mysql --datadir=/var/lib/mysql
