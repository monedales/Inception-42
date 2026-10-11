#!/bin/bash
set -e   # stop the script if any command fails

# =============================================================================
# NGINX entrypoint: generates a self-signed TLS certificate (first run only),
# using the certificate fields from the .env, then launches nginx (via exec "$@").
# =============================================================================

mkdir -p /etc/nginx/ssl

# Generate a self-signed certificate only if it doesn't exist yet.
# Fields (country, state, ...) come from the .env variables.
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
	echo "[nginx] Generating self-signed TLS certificate..."
	openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=${CERT_COUNTRY}/ST=${CERT_STATE}/L=${CERT_CITY}/O=${CERT_ORG}/OU=${CERT_UNIT}/CN=${CERT_CN}" \
		> /dev/null 2>&1
fi

echo "[nginx] Starting nginx..."

# Replace this script with the CMD from the Dockerfile (nginx, foreground).
# exec makes nginx become PID 1 (correct lifecycle, proper signal handling).
exec "$@"
