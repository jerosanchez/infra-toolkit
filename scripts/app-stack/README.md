# App Stack Role Setup

This directory contains automation scripts to deploy and manage an application stack (Spring Boot + PostgreSQL) on Linux servers using Docker Compose. The scripts simplify the process of assigning the "app-stack" role to a newly provisioned VM, allowing you to quickly deploy your containerized applications with a production-ready database.

---

## Purpose

These scripts automate the complete lifecycle of an application stack:

- Install required dependencies (Docker, Docker Compose, PostgreSQL client, Git)
- Configure the stack using environment variables
- Deploy both application and database containers via Docker Compose
- Create a systemd service for automatic startup after reboots (service is enabled, but not started during installation)
- Provide clean uninstallation to repurpose the server for other roles

---

## Components

The directory contains the following files:

- **install.sh**: Main installation script that orchestrates the entire setup process
- **uninstall.sh**: Cleanup script that removes all stack components and configuration
- **start-app-stack.sh**: Stack startup script that launches the Docker Compose services
- **docker-compose.yml**: Docker Compose configuration for the app and Postgres database
- **.env.example**: Template file containing required environment variables
- **backup-database.sh**: Script to create compressed, timestamped backups of the database
- **cleanup-backups.sh**: Script to remove old database backups based on retention policy

---

## Prerequisites

- A Linux server with Ubuntu (recommended: Ubuntu Noble or later)
- Root or sudo access
- Network access to Docker Hub (or your private registry)

---

## Installation

Run the installation from the root of the infra-toolkit repository:

```bash
make app-stack
```

This command will:

1. Check for Docker installation and install it if missing (requires reboot)
2. Install Docker Compose, PostgreSQL client tools, and Git
3. Copy all necessary files to `/opt/app-stack/`
4. Create a systemd service named `app-stack.service`
5. Enable the service for automatic startup (the service is enabled by default)
6. To start the app stack, either reboot the server (the service will start automatically), or start it manually if you don't want to reboot

After installation, configure your stack settings:

```bash
sudo vim /opt/app-stack/.env
```

Fill in the required values:

```dotenv
# Postgres Configuration
POSTGRES_DB="appdb"
POSTGRES_USER="appuser"
POSTGRES_PASSWORD="changeme"
POSTGRES_DATA_DIR="/opt/app-stack/postgres-data"

# Application Configuration
APP_NAME="myapp"
APP_PORT="8080"
APP_IMAGE="myapp:latest"

# Docker Compose Configuration
COMPOSE_PROJECT_NAME="app-stack"
```

> **Note:** You will most likely also need to update `/opt/app-stack/docker-compose.yml` to match your application's requirements, such as image names, ports, volumes, or service definitions. Ensure both `.env` and `docker-compose.yml` are consistent for your environment.

To start the app stack after installation, you have two options:

- **Reboot the server:** The app stack will start automatically on boot.
- **Start manually without rebooting:**

    ```bash
    sudo /opt/app-stack/start-app-stack.sh
    ```

Or restart the service:

```bash
sudo systemctl restart app-stack.service
```

---

## Architecture

The Docker Compose setup includes:

### PostgreSQL Database

- **Image**: `postgres:16-alpine`
- **Purpose**: Production database for your application
- **Data Persistence**: Uses a named volume mounted to `POSTGRES_DATA_DIR`
- **Health Checks**: Ensures database is ready before starting the application

### Application Container

- **Image**: Configured via `APP_IMAGE` environment variable
- **Purpose**: Your Spring Boot application (or any containerized app)
- **Port Mapping**: Exposes the application on the configured `APP_PORT`
- **Database Connection**: Automatically configured to connect to the Postgres service

### Networking

- Both containers run on an isolated bridge network for secure communication
- Only the application port is exposed to the host

---

## Deploying Your Application

To deploy only your application (without affecting the database):

```bash
cd /opt/app-stack
docker compose up -d --build app
```

This command will:

1. Rebuild your application container with the latest image
2. Restart only the application service
3. Leave the database running with all data intact

---

## Managing the Stack

### Check Service Status

```bash
sudo systemctl status app-stack.service
```

### View Logs

```bash
cd /opt/app-stack
docker compose logs -f
```

### Stop the Stack

```bash
sudo systemctl stop app-stack.service
```

### Restart the Stack

```bash
sudo systemctl restart app-stack.service
```

---

## Database Management

### Connect to PostgreSQL

```bash
docker exec -it app-stack-postgres psql -U appuser -d appdb
```

### Backup Database

Automatic backups are scheduled via cron and stored in `/opt/app-stack/backups/` with timestamped filenames. You can also run a manual backup at any time:

```bash
cd /opt/app-stack
sudo ./backup-database.sh
```

#### Manual Restore

```bash
zcat /opt/app-stack/backups/appdb-YYYYMMDD-HHMMSS.sql.gz | docker exec -i app-stack-postgres psql -U appuser -d appdb
```

#### Automated Cleanup

Old backups are automatically cleaned up daily by a scheduled cron job (default retention: 7 days, configurable in `.env`). You can run it manually:

```bash
cd /opt/app-stack
sudo ./cleanup-backups.sh
```

---

## Uninstallation

To completely remove the app-stack role and all associated data:

```bash
cd /home/your-user/infra-toolkit/scripts/app-stack
sudo bash uninstall.sh
```

**Warning**: This will permanently delete all database data stored in `POSTGRES_DATA_DIR`.

All scheduled backup cleanup jobs will also be removed automatically.

---

## Security Considerations

- Change the default `POSTGRES_PASSWORD` before deploying to production
- Consider using Docker secrets or external secret management for sensitive values
- If exposing the application externally, use Tailscale, a reverse proxy, or VPN
- Regularly update container images to patch security vulnerabilities
- Back up your database regularly
- Extract local backup files to external media or remote storage for disaster recovery

---

## Troubleshooting

### Service Fails to Start

Check service logs:

```bash
sudo journalctl -u app-stack.service -f
```

### Database Connection Issues

Verify database is healthy:

```bash
docker compose ps
docker compose logs postgres
```

### Port Already in Use

Check if another service is using the configured port:

```bash
sudo lsof -i :8080
```

---

## CI/CD Pipeline Integration

To integrate this app stack with your CI/CD pipeline, follow these steps:

**Build and Push Image:**

- Build your application Docker image in the pipeline.
- Push the image to your local registry (e.g., `registry.local:5000/myapp:latest`).

**Deploy Step:**

- On your deployment VM, update the `APP_IMAGE` variable in `/opt/app-stack/.env` to reference the new image tag (e.g., `registry.local:5000/myapp:latest`).
- Trigger a redeploy using Docker Compose:

    ```bash
    cd /opt/app-stack
    docker compose pull app
    docker compose up -d --build app
    ```

- This will pull the latest image and restart only the application container, leaving the database untouched.

**Automation:**

- You can automate the deploy step by using SSH, Ansible, or a remote script from your CI/CD pipeline after the image push completes.
- Example (using SSH):

    ```bash
    ssh user@deploy-vm 'cd /opt/app-stack && docker compose pull app && docker compose up -d --build app'
    ```

**Tip:**

- Ensure your registry and deployment VM are accessible from your CI/CD runner.
- Use environment-specific `.env` files for staging and production.
- Optionally, automate `.env` updates with your pipeline for versioned deployments.

## Future Enhancements

- Include monitoring and alerting setup
- Integration with CI/CD pipelines
- SSL/TLS configuration for production deployments
