FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Custom config: make mariadb listen on all interfaces (not just localhost),
# since other containers need to reach it over the docker network.
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

# ENTRYPOINT, not CMD-with-a-loop: init_db.sh does one-time setup then
# execs mysqld as PID 1 in the foreground. No daemonizing, no tail -f.
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
