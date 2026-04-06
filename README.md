# GLPI Docker Deployment

Production-oriented Docker image for **GLPI 11**, designed to run behind a reverse proxy such as **Traefik** or **Caddy**, with persistent storage and a non-root runtime.

This project provides a reusable GLPI container architecture including:

- GLPI container
- MariaDB container
- optional GLPI cron container
- reverse proxy integration
- persistent volumes
- environment-based configuration

---

# Architecture

Typical deployment:

Internet
│
Reverse Proxy (Traefik / Caddy)
│
GLPI Container
│
MariaDB Container

Optional:

GLPI Cron Container

The reverse proxy handles:

- HTTPS
- domain routing
- security middlewares
- rate limiting

---

# Features

- GLPI 11
- Apache + PHP runtime
- external database support
- persistent storage
- reverse proxy ready
- environment-driven configuration
- non-root runtime execution
- cron compatible container
- reusable Docker image

---

# Storage Layout

The container uses the following directories:

| Path | Purpose |
|-----|------|
| `/etc/glpi` | configuration |
| `/var/lib/glpi` | persistent application data |
| `/var/log/glpi` | logs |

GLPI configuration is managed through:

downstream.php
local_define.php

This allows GLPI to keep sensitive and dynamic data outside the web root.

---

# Docker Image

Pull the image:

docker pull YOUR_DOCKERHUB_USERNAME/glpi:11.0.6

---

# Example docker-compose

services:

db:
- image: mariadb:lts
- env_file:
- .env
environment:
- MARIADB_DATABASE: ${GLPI_DB_NAME}
- MARIADB_USER: ${GLPI_DB_USER}
- MARIADB_PASSWORD: ${GLPI_DB_PASSWORD}
- MARIADB_ROOT_PASSWORD: ${GLPI_DB_ROOT_PASSWORD}
volumes:
- glpi_db:/var/lib/mysql
- restart: unless-stopped

glpi:
image: ${GLPI_IMAGE}
env_file:
- .env
depends_on:
- db
volumes:
- glpi_config:/etc/glpi
- glpi_var:/var/lib/glpi
- glpi_logs:/var/log/glpi
restart: unless-stopped

labels:
  - traefik.enable=true
  - traefik.docker.network=${TRAEFIK_NETWORK}
  - traefik.http.routers.glpi.rule=Host(`${GLPI_HOST}`)
  - traefik.http.routers.glpi.entrypoints=websecure
  - traefik.http.routers.glpi.tls=true
  - traefik.http.routers.glpi.tls.certresolver=${TRAEFIK_CERTRESOLVER}
  - traefik.http.routers.glpi.middlewares=${TRAEFIK_MIDDLEWARES}
  - traefik.http.services.glpi.loadbalancer.server.port=80

glpi-cron:
image: ${GLPI_IMAGE}
env_file:
- .env
depends_on:
- db
volumes:
- glpi_config:/etc/glpi
- glpi_var:/var/lib/glpi
- glpi_logs:/var/log/glpi
restart: unless-stopped

entrypoint: []
command:
  - /bin/sh
  - -c
  - |
    while true; do
      php /var/www/glpi/front/cron.php || true
      sleep "${GLPI_CRON_INTERVAL:-300}"
    done

    volumes:
glpi_db:
glpi_config:
glpi_var:
glpi_logs:

---

# Environment variables

Create a `.env` file based on `.env.example`.

Example:

GLPI_IMAGE=abed4/glpi:11.0.6

GLPI_DB_NAME=glpi
GLPI_DB_USER=glpi
GLPI_DB_PASSWORD=strong_password
GLPI_DB_ROOT_PASSWORD=strong_root_password

GLPI_HOST=glpi.example.com

TRAEFIK_NETWORK=proxy
TRAEFIK_CERTRESOLVER=letsencrypt
TRAEFIK_MIDDLEWARES=secure-headers@file

GLPI_CRON_INTERVAL=300

---

# Installation

Start the stack:

docker compose up -d

Then open your browser:

https://glpi.example.com

Follow the GLPI installation wizard.

Database host:

db

---

# Security notes

This repository intentionally excludes:

- personal domains
- real credentials
- infrastructure-specific configuration

Best practices:

- use strong passwords
- do not commit `.env`
- use Docker secrets in production
- keep the database container internal
- expose only the reverse proxy publicly

---

# Reverse Proxy

This project assumes a reverse proxy handles:

- HTTPS
- TLS certificates
- routing
- security middlewares

Example compatible proxies:

- Traefik
- Caddy
- Nginx

---

# License
