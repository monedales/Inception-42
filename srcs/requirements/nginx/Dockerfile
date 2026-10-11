# NGINX reverse proxy + TLS — built from Debian bookworm (penultimate stable)
FROM debian:bookworm

# nginx (web server / reverse proxy) + openssl (to generate the TLS cert)
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Our nginx config (listens on 443 only, TLS, proxies PHP to wordpress:9000)
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Our init script: generates the self-signed cert, then launches nginx
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# nginx listens on 443 (the only public entry point of the whole stack)
EXPOSE 443

# ENTRYPOINT runs our script; it ends with `exec "$@"`, which runs the CMD
# below (nginx in the foreground -> PID 1).
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["nginx", "-g", "daemon off;"]
