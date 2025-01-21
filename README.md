#### Authors : Papazian Loïc & Maldonado Clément
# Doc 

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/Narigane3/docker-swarm-bookstack.git
```

### 2. Create the docker network

```bash
    docker network create traefik_network
```

### 3. Create the .env file
    
```bash
    cp .env.example .env
```
Edit the .env file and set the values for the environment variables.

- `BASIC_AUTH`- Execute the following command to generate  the value for the `BASIC_AUTH` variable.
```bash
sh ./generate_user_hash.sh
```
- `APP_KEY` - Execute the following command to generate the value for the `APP_KEY` variable.
```bash
base64 /dev/urandom | head -c 32
```
### 4. Start the services
```bash
docker compose --env-file .env up --build -d
```
### 5. Launch the application
```bash
docker compose up -d
```

## Configuration
### .env File Variables

- `PUID` - User ID for the Docker container.
- `PGID` - Group ID for the Docker container.
- `TRAEFIK_DOMAIN` - Domain name for Traefik.
- `LETSENCRYPT_EMAIL` - Email address for Let's Encrypt notifications.
- `BASIC_AUTH` - Basic authentication hash (generated using `sh generate_user_hash.sh`).
- `HTTP_PORT` - HTTP port for Traefik.
- `HTTPS_PORT` - HTTPS port for Traefik.
- `DOCKER_SOCK` - Path to Docker socket.
- `MYSQL_ROOT_PASSWORD` - Root password for MySQL.
- `MYSQL_DATABASE` - Name of the MySQL database.
- `MYSQL_USER` - MySQL user name.
- `MYSQL_PASSWORD` - Password for the MySQL user.
- `MYSQL_PORT` - Port for MySQL.
- `APP_URL` - URL for the BookStack application.
- `APP_KEY` - Application key for BookStack (generated using `base64 /dev/urandom | head -c 32`).
- `DB_HOST` - Hostname for the MySQL database.
- `DB_DATABASE` - Name of the MySQL database (same as `MYSQL_DATABASE`).
- `DB_USER` - MySQL user name (same as `MYSQL_USER`).
- `DB_PASS` - Password for the MySQL user (same as `MYSQL_PASSWORD`).

## Details
### Docker Compose Services

#### `proxy` Service
- **image**: Uses the `traefik:v2.9` image.
- **restart**: Always restarts the container if it stops.
- **deploy**: Specifies deployment configurations.
    - **replicas**: Number of container instances to run.
- **command**: List of Traefik commands to configure the proxy.
    - `--providers.docker=true`: Enables Docker provider.
    - `--entrypoints.web.address=:80`: Defines HTTP entry point.
    - `--entrypoints.websecure.address=:443`: Defines HTTPS entry point.
    - `--certificatesresolvers.myresolver.acme.tlschallenge=true`: Enables TLS challenge for Let's Encrypt.
    - `--certificatesresolvers.myresolver.acme.email=${LETSENCRYPT_EMAIL}`: Email for Let's Encrypt notifications.
    - `--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json`: Path to store Let's Encrypt certificates.
    - `--entrypoints.web.http.redirections.entryPoint.to=websecure`: Redirects HTTP to HTTPS.
    - `--entrypoints.web.http.redirections.entryPoint.scheme=https`: Sets redirection scheme to HTTPS.
    - `--accesslog=true`: Enables access logs.
    - `--accesslog.filepath=/logs/access.log`: Path to access log file.
    - `--accesslog.bufferingsize=100`: Buffer size for access logs.
    - `--api.dashboard=true`: Enables Traefik dashboard.
    - `--api.insecure=false`: Secures the Traefik dashboard.
- **ports**: Exposes ports.
    - `80:80`: HTTP port.
    - `443:443`: HTTPS port.
    - `8080:8080`: Traefik dashboard port.
- **volumes**: Mounts volumes.
    - `/var/run/docker.sock:/var/run/docker.sock:ro`: Docker socket for service discovery.
    - `./letsencrypt:/letsencrypt`: Stores Let's Encrypt certificates.
    - `./logs:/logs`: Stores access logs.
- **labels**: Traefik labels for routing and middleware.
    - `traefik.enable=true`: Enables Traefik for this service.
    - `traefik.http.routers.traefik.rule=Host(${TRAEFIK_DOMAIN})`: Routing rule based on domain.
    - `traefik.http.routers.traefik.service=api@internal`: Uses internal Traefik API service.
    - `traefik.http.routers.traefik.entrypoints=websecure`: Uses HTTPS entry point.
    - `traefik.http.routers.traefik.tls.certresolver=myresolver`: Uses Let's Encrypt resolver.
    - `traefik.http.middlewares.auth.basicauth.users=${BASIC_AUTH}`: Basic authentication middleware.
    - `traefik.http.routers.traefik.middlewares=auth`: Applies authentication middleware.
- **networks**: Connects to the `traefik_network`.

#### `bookstack` Service
- **image**: Uses the `linuxserver/bookstack:latest` image.
- **restart**: Always restarts the container if it stops.
- **deploy**: Specifies deployment configurations.
    - **replicas**: Number of container instances to run.
- **environment**: List of environment variables.
    - `PUID=${PUID}`: User ID for the container.
    - `PGID=${PGID}`: Group ID for the container.
    - `TZ=Etc/UTC`: Timezone setting.
    - `APP_URL=https://${APP_URL}`: URL for the BookStack application.
    - `APP_KEY=${APP_KEY}`: Application key for BookStack.
    - `DB_HOST=mysql`: MySQL database host.
    - `DB_PORT=${MYSQL_PORT}`: MySQL database port.
    - `DB_USERNAME=${MYSQL_USER}`: MySQL user name.
    - `DB_PASSWORD=${MYSQL_PASSWORD}`: MySQL user password.
    - `DB_DATABASE=${MYSQL_DATABASE}`: MySQL database name.
    - `QUEUE_CONNECTION=redis`: Queue connection setting.
- **volumes**: Mounts volumes.
    - `bookstack_data:/config`: Stores configuration and persistent data.
- **depends_on**: Specifies service dependencies.
    - `mysql`: Waits for MySQL to be available.
    - `redis`: Waits for Redis to be available.
- **labels**: Traefik labels for routing.
    - `traefik.enable=true`: Enables Traefik for this service.
    - `traefik.http.routers.bookstack.rule=Host(${APP_URL})`: Routing rule based on URL.
    - `traefik.http.routers.bookstack.entrypoints=websecure`: Uses HTTPS entry point.
    - `traefik.http.routers.bookstack.tls.certresolver=myresolver`: Uses Let's Encrypt resolver.
    - `traefik.http.services.bookstack.loadbalancer.server.port=80`: Load balancer port.
- **networks**: Connects to the `traefik_network`.

#### `mysql` Service
- **image**: Uses the `mysql:8.0` image.
- **restart**: Always restarts the container if it stops.
- **environment**: List of environment variables.
    - `MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}`: MySQL root password.
    - `MYSQL_DATABASE=${MYSQL_DATABASE}`: MySQL database name.
    - `MYSQL_USER=${MYSQL_USER}`: MySQL user name.
    - `MYSQL_PASSWORD=${MYSQL_PASSWORD}`: MySQL user password.
- **volumes**: Mounts volumes.
    - `mysql_data:/var/lib/mysql`: Stores MySQL data.
    - `./backup:/backup`: Mounts backup directory.
- **command**: Sets MySQL authentication plugin.
    - `--default-authentication-plugin=mysql_native_password`: Ensures compatibility with MySQL connections.
- **ports**: Exposes MySQL port.
    - `${MYSQL_PORT}:3306`: MySQL port.
- **networks**: Connects to the `traefik_network`.

#### `redis` Service
- **image**: Uses the `redis:latest` image.
- **restart**: Always restarts the container if it stops.
- **command**: List of Redis commands.
    - `redis-server --appendonly yes`: Enables persistent storage.
- **volumes**: Mounts volumes.
    - `redis_data:/data`: Stores Redis data.
- **networks**: Connects to the `traefik_network`.

#### `backup` Service
- **image**: Uses the `debian:latest` image.
- **restart**: Always restarts the container if it stops.
- **volumes**: Mounts volumes.
    - `./backup:/backup`: Mounts backup directory.
- **command**: Backup command.
    - `/bin/sh -c 'while true; do mysqldump -h mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} > /backup/bookstack_backup.sql; sleep 86400; done'`: Runs daily MySQL backup.
- **depends_on**: Specifies service dependencies.
    - `mysql`: Waits for MySQL to be available.
- **networks**: Connects to the `traefik_network`.

### Volumes
- **bookstack_data**: Stores BookStack data.
- **mysql_data**: Stores MySQL data.
- **redis_data**: Stores Redis data.
- **letsencrypt**: Stores Let's Encrypt certificates.

### Networks
- **traefik_network**: External network for Traefik.