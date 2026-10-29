![Docker](https://img.shields.io/badge/docker-ready-blue)
![GLPI](https://img.shields.io/badge/GLPI-11.0.7-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![Maintained](https://img.shields.io/badge/status-maintained-brightgreen)

# GLPI Docker Deployment

Production-ready Docker image for GLPI 11, designed to run behind a reverse proxy such as Traefik, Caddy, or Nginx.

This repository provides a reusable container image and a Compose example for a production-ready deployment.

---

# Project repository

GitHub repository:

https://github.com/Emusimbwa/glpi11-apache-docker

Docker Hub image:

https://hub.docker.com/r/abed4/glpi

---

# Features

- GLPI 11
- Apache + PHP runtime
- External MariaDB support
- Persistent storage
- Reverse proxy ready
- Non-root runtime
- Environment-based configuration
- Cron-compatible container

---

# Repository layout

```text
glpi11-apache-docker/
├── Dockerfile
├── .env.example
├── .gitignore
├── README.md
├── compose/
│   └── docker-compose.yaml.example
├── container/
│   ├── apache-glpi.conf.template
│   ├── downstream.php
│   ├── entrypoint.sh
│   └── local_define.php
├── scripts/
│   └── generate-secrets.sh
└── LICENSE
```

---

# Container layout

The container uses the following persistent directories:

| Path | Purpose |
| --- | --- |
| `/etc/glpi` | GLPI configuration |
| `/var/lib/glpi` | GLPI application data |
| `/var/log/glpi` | GLPI logs |

The custom GLPI configuration is loaded from:

- `container/downstream.php`
- `container/local_define.php`

This keeps configuration and runtime data outside the web root.

---

# Pull the image

```bash
docker pull abed4/glpi:11.0.7
```

---

## Deployment modes

This project supports two deployment modes.

### 1. Direct deployment without reverse proxy

Useful for local testing or simple validation.

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

- http://localhost:8080
- http://SERVER_IP:8080

Important: if GLPI is connected only to an internal network, Docker will not publish the port correctly.

### 2. Deployment behind a reverse proxy

Recommended for production.

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

- https://glpi.example.com

---

# Database configuration

During the GLPI installation wizard, set:

- Database host: `db`
- Database port: `3306`

The credentials are defined in the `.env` file.

---

# Environment configuration

Create your environment file from the example:

```bash
cp .env.example .env
```

Then edit the file and set your values.

Example variables:

```env
GLPI_IMAGE=abed4/glpi:11.0.7
GLPI_DB_NAME=glpi
GLPI_DB_USER=glpi
GLPI_DB_PASSWORD=change_me
GLPI_DB_ROOT_PASSWORD=change_me_root
GLPI_HOST=glpi.example.com
TRAEFIK_NETWORK=proxy
TRAEFIK_CERTRESOLVER=letsencrypt
TRAEFIK_MIDDLEWARES=secure-headers@file
GLPI_CRON_INTERVAL=300
```

---

# Password generation helper

A helper script is provided to generate secure passwords.

Location:

```bash
./scripts/generate-secrets.sh
```

Example output:

```env
GLPI_DB_PASSWORD=F3k9aB4wT3...
GLPI_DB_ROOT_PASSWORD=s9Ds8f93J...
```

Copy these values into your `.env` file.

---

# Reverse proxy support

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
- rebuild images regularly to receive upstream security updates
- optionally use Docker secrets in production

---

# License

No License.

---

# Links

- GitHub repository: https://github.com/Emusimbwa/glpi11-apache-docker
- Docker Hub image: https://hub.docker.com/r/abed4/glpi
