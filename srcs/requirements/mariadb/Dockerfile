# MariaDB service — built from Debian bookworm (penultimate stable version)
FROM debian:bookworm

# Install the MariaDB server and clean the apt cache in the SAME layer,
# so the downloaded package lists don't stay baked into the image.
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql/* 

# Our own server config (makes MariaDB listen on the network, not only locally)
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Our init script: it runs at container start (first-run setup + launch)
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# MariaDB listens on 3306 — documentation only, reachable via the Docker
# network (it is NOT published to the host; only NGINX:443 is public).
EXPOSE 3306

# The script becomes PID 1: it decides first-run vs normal boot, then
# exec's the mariadb daemon in the foreground (no background hacks).
ENTRYPOINT ["/usr/local/bin/setup.sh"]
