1| ![Docker](https://img.shields.io/badge/docker-ready-blue)
2| ![GLPI](https://img.shields.io/badge/GLPI-11.0.7-green)
3| ![License](https://img.shields.io/badge/license-MIT-blue)
4| ![Maintained](https://img.shields.io/badge/status-maintained-brightgreen)
5| 
6| # GLPI Docker Deployment
7| 
8| Production-ready Docker image for **GLPI 11.0.7**, designed to run behind a reverse proxy such as **Traefik**, **Caddy**, or **Nginx**.
9| 
10| This project provides a reusable container image and example deployment architecture using Docker Compose.
11| 
12| ---
13| 
14| # Project repository
15| 
16| GitHub repository:
17| 
18| https://github.com/Emusimbwa/glpi11-apache-docker
19| 
20| Docker Hub image:
21| 
22| https://hub.docker.com/r/abed4/glpi
23| 
24| ---
25| 
26| # Features
27| 
28| - GLPI 11.0.7
29| - Apache + PHP runtime
30| - External MariaDB support
31| - Persistent storage
32| - Reverse proxy ready
33| - Non-root runtime
34| - Environment-based configuration
35| - Compatible with cron container
36| 
37| # Project structure
38| ```
39| glpi11-apache-docker/
40| ├── Dockerfile                 # Container image definition
41| ├── .env.example               # Environment template
42| ├── .gitignore                 # Git ignore rules
43| ├── README.md                  # This file
44| │
45| ├── compose/
46| │   └── docker-compose.yaml.example   # Example Compose stack
47| │
48| ├── container/
49| │   ├── apache-glpi.conf.template     # Apache vhost template
50| │   ├── downstream.php                # GLPI config override
51| │   ├── entrypoint.sh                 # Runtime bootstrap
52| │   └── local_define.php              # GLPI filesystem config
53| │
54| └── scripts/
55|     └── generate-secrets.sh            # Password generation helper
56| ```
57| 
58| # Storage layout
59| 
60| The container uses the following directories:
61| 
62| | Path | Purpose |
63| |-----|------|
64| | `/etc/glpi` | configuration |
65| | `/var/lib/glpi` | persistent application data |
66| | `/var/log/glpi` | logs |
67| 
68| GLPI configuration is redirected using:
69| 
70| - `container/downstream.php`
| - `container/local_define.php`
71| 
72| This allows configuration and runtime data to stay outside the web root.
73| 
74| ---
75| 
76| # Pull the image
77| 
78| `docker pull abed4/glpi:11.0.7`
79| 
80| ---
81| 
82| ## Deployment modes
83| 
84| This project supports two deployment modes:
85| 
86| ### 1. Direct deployment without reverse proxy
87| 
88| This mode is useful for local testing or validating the image without Traefik/Caddy/Nginx.
89| 
90| In this mode, GLPI must be connected to a non-internal Docker network and exposed with a port mapping.
91| 
92| Example:
93| 
94| ```yaml
95| services:
96|   glpi:
97|     image: ${GLPI_IMAGE}
98|     ports:
99|       - "8080:80"
100|     networks:
101|       - backend
102|       - public_test
103| 
104| networks:
105|   backend:
106|     internal: true
107| 
108|   public_test:
109|     driver: bridge
110| ```
111| 
112| Access GLPI at:
113| 
114| http://localhost:8080
115| 
116| or:
117| 
118| http://SERVER_IP:8080
119| 
120| Important: if GLPI is connected only to an internal: true network, Docker will not publish the port correctly.
121| 
122| ### 2. Deployment behind a reverse proxy
123| 
124| This mode is recommended for production.
125| 
126| In this mode:
127| 
128| - GLPI is not directly exposed with ports
129| - Traefik/Caddy/Nginx handles public access
130| - GLPI is connected to the reverse proxy network
131| - MariaDB stays on an internal backend network
132| 
133| Example with Traefik:
134| 
135| ```yaml
136| services:
137|   glpi:
138|     image: ${GLPI_IMAGE}
139|     networks:
140|       - backend
141|       - proxy
142|     labels:
143|       - traefik.enable=true
144|       - traefik.docker.network=${TRAEFIK_NETWORK}
145|       - traefik.http.routers.glpi.rule=Host(`${GLPI_HOST}`)
146|       - traefik.http.routers.glpi.entrypoints=websecure
147|       - traefik.http.routers.glpi.tls=true
148|       - traefik.http.services.glpi.loadbalancer.server.port=80
149| 
150| networks:
151|   backend:
152|     internal: true
153| 
154|   proxy:
155|     external: true
156|     name: ${TRAEFIK_NETWORK}
157| ```
158| 
159| Access GLPI at:
160| 
161| https://glpi.example.com
162| 
163| ---
164| 
165| # Database configuration
166| 
167| During the GLPI installation wizard, use:
168| 
169| - `Database host:`
170| db
171| 
172| - `Database port:`
173| 330
174| 
175| The database credentials are defined in the `.env` file.
176| 
177| ---
178| 
179| # Environment configuration
180| 
181| Create your environment file from the example:
182| - `cp .env.example .env`
183| 
184| Edit the `.env` file and set your values.
185| 
186| Example variables:
187| 
188| `GLPI_IMAGE=`abed4/glpi:11.0.7
189| 
190| `GLPI_DB_NAME=`glpi
191| 
192| `GLPI_DB_USER=`glpi
193| 
194| `GLPI_DB_PASSWORD=`change_me
195| 
196| `GLPI_DB_ROOT_PASSWORD=`change_me_root
197| 
198| `GLPI_HOST=`glpi.example.com
199| 
200| `TRAEFIK_NETWORK=`proxy
201| 
202| `TRAEFIK_CERTRESOLVER=`letsencrypt
203| 
204| `TRAEFIK_MIDDLEWARES=`secure-headers@file
205| 
206| `GLPI_CRON_INTERVAL=`300
207| 
208| ---
209| 
210| # Password generation script
211| 
212| A helper script is provided to generate secure passwords.
213| 
214| Location:
215| - `scripts/generate-secrets.sh`
216| 
217| Run it:
218| - `chmod +x scripts/generate-secrets.sh`
219| - `./scripts/generate-secrets.sh`
220| 
221| Example output:
222| - `GLPI_DB_PASSWORD=F3k9aB4wT3...`
223| - `GLPI_DB_ROOT_PASSWORD=s9Ds8f93J...`
224| 
225| Copy these values into your `.env` file.
226| 
227| ---
228| 
229| # Reverse proxy
230| 
231| This container is designed to run behind a reverse proxy.
232| 
233| Compatible proxies:
234| 
235| - Traefik
236| - Caddy
237| - Nginx
238| 
239| The reverse proxy should handle:
240| 
241| - HTTPS
242| - TLS certificates
243| - routing
244| - security middlewares
245| 
246| ---
247| 
248| # Security recommendations
249| 
250| Container images should be rebuilt regularly to receive upstream security updates from:
251| 
252| - Debian
253| - PHP
254| - Apache
255| - system libraries
256|   
257| - never commit `.env`
258| - use strong passwords
259| - restrict database access to internal Docker networks
260| - expose only the reverse proxy publicly
261| - optionally use Docker secrets in production
262| 
263| ---
264| 
265| # License
266| 