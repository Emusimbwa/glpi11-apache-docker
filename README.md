![Docker](https://img.shields.io/badge/docker-ready-blue)
![GLPI](https://img.shields.io/badge/GLPI-11.0.7-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![Maintained](https://img.shields.io/badge/status-maintained-brightgreen)

# GLPI Docker Deployment

Production-ready Docker image for **GLPI 11.0.7**, designed to run behind a reverse proxy such as **Traefik**, **Caddy**, or **Nginx**.

This project provides a reusable container image and example deployment architecture using Docker Compose.

---

# Project repository

GitHub repository:

https://github.com/Emusimbwa/glpi11-apache-docker

Docker Hub image:

https://hub.docker.com/r/abed4/glpi

---

# Features

- GLPI 11.0.7
- Apache + PHP runtime
- External MariaDB support
- Persistent storage
- Reverse proxy ready
- Non-root runtime
- Environment-based configuration
- Compatible with cron container

# Project structure
```
glpi11-apache-docker/
├── Dockerfile                 # Container image definition
├── downstream.php             # GLPI configuration override
├── local_define.php           # GLPI settings
├── README.md                  # This file
├── .env.example               # Environment template
├── .gitignore                 # Git ignore rules
│
├── scripts
│   └── generate-secrets.sh    # Password generation helper
│
└── docker-compose.yaml
```

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

`docker pull abed4/glpi:11.0.7`

---

## Deployment modes

This project supports two deployment modes:

### 1. Direct deployment without reverse proxy

This mode is useful for local testing or validating the image without Traefik/Caddy/Nginx.

In this mode, GLPI must be connected to a non-internal Docker network and exposed with a port mapping.

Example:

```yaml
services:
  glpi:
    image: ${GLPI_IMAGE}
    ports:
      - "8080:80"
    networks:
      - backend
      - public_test

networks:
  backend:
    internal: true

  public_test:
    driver: bridge
```

Access GLPI at:

http://localhost:8080

or:

http://SERVER_IP:8080

Important: if GLPI is connected only to an internal: true network, Docker will not publish the port correctly.

### 2. Deployment behind a reverse proxy

This mode is recommended for production.

In this mode:

- GLPI is not directly exposed with ports
- Traefik/Caddy/Nginx handles public access
- GLPI is connected to the reverse proxy network
- MariaDB stays on an internal backend network

Example with Traefik:

```yaml
services:
  glpi:
    image: ${GLPI_IMAGE}
    networks:
      - backend
      - proxy
    labels:
      - traefik.enable=true
      - traefik.docker.network=${TRAEFIK_NETWORK}
      - traefik.http.routers.glpi.rule=Host(`${GLPI_HOST}`)
      - traefik.http.routers.glpi.entrypoints=websecure
      - traefik.http.routers.glpi.tls=true
      - traefik.http.services.glpi.loadbalancer.server.port=80

networks:
  backend:
    internal: true

  proxy:
    external: true
    name: ${TRAEFIK_NETWORK}
```

Access GLPI at:

https://glpi.example.com

---

# Database configuration

During the GLPI installation wizard, use:

- `Database host:`
db

- `Database port:`
330

The database credentials are defined in the `.env` file.

---

# Environment configuration

Create your environment file from the example:
- `cp .env.example .env`

Edit the `.env` file and set your values.

Example variables:

`GLPI_IMAGE=`abed4/glpi:11.0.7

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

Container images should be rebuilt regularly to receive upstream security updates from:

- Debian
- PHP
- Apache
- system libraries
  
- never commit `.env`
- use strong passwords
- restrict database access to internal Docker networks
- expose only the reverse proxy publicly
- optionally use Docker secrets in production

---

# License
