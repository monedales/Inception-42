#!/bin/bash
set -e   # stop the script if any command fails

# =============================================================================
# WordPress entrypoint: waits for MariaDB, then (on first run) downloads and
# configures WordPress, creates the site + two users. Finally runs php-fpm in
# the foreground (exec -> PID 1).
# =============================================================================

# ---- Load secrets (files hold only the password text) -----------------------
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# WordPress lives here (backed by our named volume)
cd /var/www/html

# ---- Wait for MariaDB to be ready (the anti-502 retry) ----------------------
# The container may start before MariaDB is accepting connections. We keep
# pinging it over the network until it answers, instead of failing early.
echo "[wp] Waiting for MariaDB at mariadb:3306..."
until mariadb-admin ping --host=mariadb --user="$MYSQL_USER" --password="$DB_PASSWORD" --silent 2>/dev/null; do
	sleep 2
done
echo "[wp] MariaDB is up."

# ---- First run? -------------------------------------------------------------
# If wp-config.php doesn't exist yet, WordPress was never set up here.
if [ ! -f "wp-config.php" ]; then

	echo "[wp] First run: installing WordPress..."

	# 1) Download the WordPress core files into the current directory
	wp core download --allow-root

	# 2) Generate wp-config.php with DB credentials (from .env + secret)
	wp config create --allow-root \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="mariadb:3306"

	# 3) Install WordPress: creates the site and the ADMIN user (not 'admin')
	wp core install --allow-root \
		--url="https://$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email

	# 4) Create the second, regular user
	wp user create --allow-root \
		"$WP_USER" "$WP_USER_EMAIL" \
		--role="$WP_USER_ROLE" \
		--user_pass="$WP_USER_PASSWORD"

	echo "[wp] WordPress installed."
else
	echo "[wp] WordPress already configured: skipping install."
fi

# ---- Fix ownership so php-fpm (www-data) can read/write the files -----------
chown -R www-data:www-data /var/www/html

# ---- Run php-fpm in the FOREGROUND (exec -> PID 1) --------------------------
# -F forces foreground; without it php-fpm would daemonize and the container
# would exit immediately.
echo "[wp] Starting php-fpm..."
exec php-fpm8.2 -F
