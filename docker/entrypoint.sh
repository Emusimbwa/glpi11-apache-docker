#!/bin/sh
set -eu

# Valeurs par défaut
: "${APACHE_SERVER_NAME:=localhost}"
: "${APACHE_DOCUMENT_ROOT:=/var/www/glpi/public}"
: "${APACHE_LISTEN_PORT:=8080}"

# si local_define absent (volume vide), le recopier depuis une copie “seed”
if [ ! -f /etc/glpi/local_define.php ] && [ -f /usr/local/share/glpi/local_define.php ]; then
  cp /usr/local/share/glpi/local_define.php /etc/glpi/local_define.php
fi

# Crée les dossiers attendus si volume vide
mkdir -p /etc/glpi /var/lib/glpi /var/log/glpi

# Sous-dossiers GLPI_VAR_DIR (conformes à ton local_define.php)
mkdir -p \
  /var/lib/glpi/_cache \
  /var/lib/glpi/_cron \
  /var/lib/glpi/_graphs \
  /var/lib/glpi/_locales \
  /var/lib/glpi/_lock \
  /var/lib/glpi/_pictures \
  /var/lib/glpi/_plugins \
  /var/lib/glpi/_rss \
  /var/lib/glpi/_sessions \
  /var/lib/glpi/_tmp \
  /var/lib/glpi/_uploads \
  /var/lib/glpi/_inventories \
  /var/lib/glpi/_themes

# Seed config si volume vide
if [ ! -f /etc/glpi/local_define.php ] && [ -f /usr/local/share/glpi/local_define.php ]; then
  cp /usr/local/share/glpi/local_define.php /etc/glpi/local_define.php
fi

# Seed downstream si absent
if [ ! -f /var/www/glpi/inc/downstream.php ] && [ -f /usr/local/share/glpi/downstream.php ]; then
  cp /usr/local/share/glpi/downstream.php /var/www/glpi/inc/downstream.php
fi

# Génération du vhost Apache depuis le template
envsubst '${APACHE_SERVER_NAME} ${APACHE_DOCUMENT_ROOT} ${APACHE_LISTEN_PORT}' \
  < /usr/local/share/apache2/apache-glpi.conf.template \
  > /etc/apache2/sites-available/000-default.conf

ln -sf /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf

# Droits (important avec volumes)
chown -R www-data:www-data /etc/glpi /var/lib/glpi /var/log/glpi /var/www/glpi

exec "$@"

