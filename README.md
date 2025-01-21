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