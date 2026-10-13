#!/bin/bash
set -e   # stop the script if any command fails

# =============================================================================
# MariaDB entrypoint: on first run it initializes the database, creates the
# WordPress DB and users; on later runs it skips setup. Finally it launches
# the daemon in the foreground (exec -> PID 1).
# =============================================================================

# ---- Load secrets (files hold only the password text) -----------------------
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Ensure the socket directory exists with the right ownership
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# ---- First run? -------------------------------------------------------------
# /var/lib/mysql/mysql holds MariaDB's internal system tables. If it's missing,
# the database has never been initialized -> this is the first run.
if [ ! -d "/var/lib/mysql/mysql" ]; then

	echo "[setup.sh] First run: initializing MariaDB..."

	# Create the internal system tables in the data directory
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	# Start a TEMPORARY server in the background, with networking off, just to
	# run our SQL setup safely (no external connections during init).
	mariadbd --user=mysql --skip-networking &
	MARIADB_PID=$!

	# Wait until the temporary server is ready to accept local commands
	until mariadb-admin ping --silent; do
		sleep 1
	done

	# Run the SQL setup against the temporary server
	mariadb << EOF
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;

CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';

FLUSH PRIVILEGES;
EOF

	# Cleanly stop the temporary server before launching the real one
	mariadb-admin --user=root --password="$DB_ROOT_PASSWORD" shutdown
	wait "$MARIADB_PID"

	echo "[setup.sh] Initialization done."
else
	echo "[setup.sh] Data directory already exists: skipping initialization."
fi

# ---- Launch the real server in the FOREGROUND -------------------------------
# exec replaces this script, so mariadbd becomes PID 1 (correct lifecycle,
# proper signal handling, no background hacks).
echo "[setup.sh] Starting MariaDB..."
exec mariadbd --user=mysql
