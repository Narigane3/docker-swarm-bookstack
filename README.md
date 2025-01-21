#### Authors: Papazian Loïc & Maldonado Clément

# Documentation

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/Narigane3/docker-swarm-bookstack.git
```

### 2. Initialize Docker Swarm
```bash
docker swarm init
```

### 3. Add a Worker Node
On the manager node, retrieve the join token:
```bash
docker swarm join-token worker
```
On the worker node, run the command provided by the manager to join the swarm:
```bash
docker swarm join --token <worker_token> <manager_ip>:2377
```

### 4. Create the Docker network
```bash
docker network create --driver overlay traefik_network
```

### 5. Create the .env file
```bash
cp .env.example .env
```
Edit the `.env` file and set the values for the environment variables.

- `BASIC_AUTH` - Execute the following command to generate the value for the `BASIC_AUTH` variable.
```bash
sh ./generate_user_hash.sh
```
- `APP_KEY` - Execute the following command to generate the value for the `APP_KEY` variable.
```bash
base64 /dev/urandom | head -c 32
```

### 6. Deploy the services using Docker Swarm
```bash
docker stack deploy -c docker-compose.yml bookstack
```

### 7. Verify Running Services
```bash
docker service ls
```

## Configuration
### .env File Variables

- `PUID`, `PGID`: User and Group ID for the Docker container.
- `TRAEFIK_DOMAIN`: Domain name for Traefik.
- `LETSENCRYPT_EMAIL`: Email for Let's Encrypt notifications.
- `BASIC_AUTH`: Basic authentication hash.
- `HTTP_PORT`, `HTTPS_PORT`: Ports for Traefik.
- `DOCKER_SOCK`: Path to Docker socket.
- `MYSQL_*`: MySQL database credentials.
- `APP_URL`, `APP_KEY`: URL and application key for BookStack.
- `DB_*`: Database connection details.

## Docker Compose Services

### `proxy` (Traefik)
- Image: `traefik:v2.9`
- High availability with `replicas: 2`, running only on manager nodes.
- Detects and routes traffic to services automatically.
- Uses Let's Encrypt for SSL certificates.
- Runs in Docker Swarm mode with overlay networking.

### `bookstack`
- Image: `linuxserver/bookstack:latest`
- Runs 3 replicas for high availability.
- Uses Redis for caching and session management.
- Depends on MySQL and Redis.

### `mysql`
- Image: `mysql:8.0`
- Single replica to ensure data consistency.
- Includes health checks to monitor database status.
- Backed up by a `backup` service.

### `redis`
- Image: `redis:latest`
- Runs 2 replicas for redundancy.
- Ensures persistent storage with append-only mode.

### `backup`
- Image: `debian:latest`
- Automates daily database backups.

### Volumes & Networks
- `bookstack_data`, `mysql_data`, `redis_data`: Persistent storage.
- `letsencrypt`: Stores SSL certificates.
- `traefik_network`: External overlay network for Swarm mode.
