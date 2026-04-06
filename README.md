# GLPI Docker Deployment

Production-ready Docker image for **GLPI 11.0.6**, designed to run behind a reverse proxy such as **Traefik**, **Caddy**, or **Nginx**.

This project provides a reusable container image and example deployment architecture using Docker Compose.

---

# Project repository

GitHub repository:

https://github.com/Emusimbwa/glpi11-apache-docker

Docker Hub image:

https://hub.docker.com/r/abed4/glpi

---

# Features

- GLPI 11.0.6
- Apache + PHP runtime
- External MariaDB support
- Persistent storage
- Reverse proxy ready
- Non-root runtime
- Environment-based configuration
- Compatible with cron container

---

# Project structure

├── Dockerfile

├── downstream.php

├── local_define.php

├── README.md

├── .env.example

│

├── scripts

│ └── generate-secrets.sh

│

└── src

|     └── docker-compose.yam

---

# Storage layout

The container uses the following directories:

| Path | Purpose |
|-----|------|
| `/etc/glpi` | configuration |
| `/var/lib/glpi` | persistent application data |
| `/var/log/glpi` | logs |

GLPI configuration is redirected using:

- `downstream.php`
- `local_define.php`

This allows configuration and runtime data to stay outside the web root.

---

# Pull the image

`docker pull abed4/glpi:11.0.6`

---

# Example deployment

The example Docker Compose configuration is located in:

`src/docker-compose.yaml`

Example usage:

- `cd src`
- `docker compose up -d`

---

# Database configuration

During the GLPI installation wizard, use:

- `Database host:`
db

- `Database port:`
3306

The database credentials are defined in the `.env` file.

---

# Environment configuration

Create your environment file from the example:
- `cp .env.example .env`

Edit the `.env` file and set your values.

Example variables:

`GLPI_IMAGE=`abed4/glpi:11.0.6

`GLPI_DB_NAME=`glpi

`GLPI_DB_USER=`glpi

`GLPI_DB_PASSWORD=`change_me

`GLPI_DB_ROOT_PASSWORD=`change_me_root

`GLPI_HOST=`glpi.example.com

`TRAEFIK_NETWORK=`proxy

`TRAEFIK_CERTRESOLVER=`letsencrypt

`TRAEFIK_MIDDLEWARES=`secure-headers@file

`GLPI_CRON_INTERVAL=`300

---

# Password generation script

A helper script is provided to generate secure passwords.

Location:
- `scripts/generate-secrets.sh`

Run it:
- `chmod +x scripts/generate-secrets.sh`
- `./scripts/generate-secrets.sh`

Example output:
- `GLPI_DB_PASSWORD=F3k9aB4wT3...`
- `GLPI_DB_ROOT_PASSWORD=s9Ds8f93J...`

Copy these values into your `.env` file.

---

# Reverse proxy

This container is designed to run behind a reverse proxy.

Compatible proxies:

- Traefik
- Caddy
- Nginx

The reverse proxy should handle:

- HTTPS
- TLS certificates
- routing
- security middlewares

---

# Security recommendations

- never commit `.env`
- use strong passwords
- restrict database access to internal Docker networks
- expose only the reverse proxy publicly
- optionally use Docker secrets in production

---

# License
