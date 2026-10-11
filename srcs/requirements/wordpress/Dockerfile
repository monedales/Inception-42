# WORDPRESS service — built from Debian bookworm (penultimate stable version)
FROM debian:bookworm

# Install php-fpm + the PHP extensions WordPress needs, wp-cli deps and the mariadb client. NO nginx here (that lives in its own container).
#   php8.2-fpm      -> PHP processor in FastCGI mode (talks to NGINX on :9000)
#   php8.2-mysqli   -> lets PHP connect to the MariaDB database (required)
#   php8.2-gd       -> image handling (thumbnails, resizing uploads)
#   php8.2-curl     -> HTTP requests from PHP (updates, plugins)
#   php8.2-mbstring -> multibyte text (accents / PT-BR characters)
#   mariadb-client  -> 'mariadb' CLI, used to check the DB is up and to debug
#   curl            -> used to download wp-cli
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysqli \
    php8.2-gd \
    php8.2-curl \
    php8.2-mbstring \
    mariadb-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install wp-cli (command-line tool to download and configure WordPress)
RUN curl -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# php-fpm pool config: make it listen on TCP 9000 for the Docker network
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Our init script: installs + configures WordPress, then runs php-fpm
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# WordPress files live here (this path is backed by our named volume)
WORKDIR /var/www/html

# php-fpm listens on 9000 -> documentation only, reachable via the Docker
# network (NOT published to the host; only NGINX:443 is public).
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
