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

