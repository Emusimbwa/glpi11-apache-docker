FROM php:8.5.11-apache-trixie

ARG GLPI_VERSION=11.0.9
ARG GLPI_URL=https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz

ENV TZ=Europe/Paris \
    APACHE_DOCUMENT_ROOT=/var/www/glpi/public \
    APACHE_SERVER_NAME=localhost \
    APACHE_LISTEN_PORT=80

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Dépendances + extensions PHP
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gettext-base \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    zlib1g-dev \
    libicu-dev \
    libxml2-dev \
    libldap2-dev \
    libbz2-dev \
  ; \
  docker-php-ext-configure gd --with-freetype --with-jpeg; \
  docker-php-ext-install -j"$(nproc)" \
    gd intl mysqli pdo pdo_mysql bz2 zip exif bcmath soap gettext; \
  docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/; \
  docker-php-ext-install -j"$(nproc)" ldap; \
  docker-php-source delete; \
  apt-get purge -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    zlib1g-dev \
    libicu-dev \
    libxml2-dev \
    libldap2-dev \
    libbz2-dev \
  ; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Modules Apache utiles
RUN set -eux; \
  a2enmod rewrite headers expires

# Téléchargement GLPI
RUN set -eux; \
  install -d /var/www /etc/glpi /var/lib/glpi /var/log/glpi /usr/local/share/glpi; \
  cd /var/www; \
  curl -fsSL "${GLPI_URL}" -o "glpi-${GLPI_VERSION}.tgz"; \
  tar -xzf "glpi-${GLPI_VERSION}.tgz"; \
  rm -f "glpi-${GLPI_VERSION}.tgz"; \
  if [ -d /var/www/glpi/config ]; then mv /var/www/glpi/config /etc/glpi; fi; \
  if [ -d /var/www/glpi/files ]; then mv /var/www/glpi/files /var/lib/glpi; fi; \
  if [ -d /var/lib/glpi/_log ]; then mv /var/lib/glpi/_log /var/log/glpi; fi; \
  chown -R www-data:www-data /var/www/glpi /etc/glpi /var/lib/glpi /var/log/glpi

# Fichiers GLPI custom
COPY local_define.php /usr/local/share/glpi/local_define.php
COPY downstream.php /usr/local/share/glpi/downstream.php
COPY --chown=www-data:www-data downstream.php /var/www/glpi/inc/downstream.php
COPY --chown=www-data:www-data local_define.php /etc/glpi/local_define.php

# Template Apache + entrypoint
COPY apache-glpi.conf.template /usr/local/share/apache2/apache-glpi.conf.template
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Prépare Apache pour tourner sans root sur 80
RUN set -eux; \
  sed -ri 's!^Listen 80$!Listen ${APACHE_LISTEN_PORT}!g' /etc/apache2/ports.conf; \
  rm -f /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-available/000-default.conf; \
  touch /var/log/apache2/access.log /var/log/apache2/error.log; \
  chown -R www-data:www-data /var/log/apache2 /etc/apache2 /var/run/apache2 /var/lock/apache2

VOLUME ["/etc/glpi", "/var/lib/glpi", "/var/log/glpi"]

EXPOSE 80

USER www-data

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
