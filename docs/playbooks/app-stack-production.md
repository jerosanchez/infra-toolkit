# App Stack Production Setup Playbook

## Introduction

This playbook guides you through setting up a production-ready Spring Boot + PostgreSQL app stack on a dedicated VM using the infra-toolkit app-stack role. It covers installation, configuration, and best practices for a secure, maintainable deployment.

## Requirements

- A provisioned Ubuntu VM (recommended: Ubuntu Noble or later)
- Root or sudo access to the VM
- infra-toolkit repository cloned locally
- Application Docker image available in your local registry
- SSH access to the VM

## Step-by-Step Instructions

1. **Clone the infra-toolkit repository**

    ```bash
    git clone https://github.com/jerosanchez/infra-toolkit.git
    cd infra-toolkit
    ```

2. **Install the app-stack role**

    ```bash
    make app-stack
    ```

    This will copy all necessary files to `/opt/app-stack/`, install dependencies, and set up a systemd service.

3. **Configure environment variables**

    Edit the `.env` file to match your production settings:

    ```bash
    sudo vim /opt/app-stack/.env
    ```

    Example configuration:

    ```dotenv
    POSTGRES_DB="prod_db"
    POSTGRES_USER="prod_user"
    POSTGRES_PASSWORD="securepassword"
    POSTGRES_DATA_DIR="/opt/app-stack/postgres-data"
    APP_NAME="myapp"
    APP_PORT="8080"
    APP_IMAGE="registry.local:5000/myapp:latest"
    COMPOSE_PROJECT_NAME="app-stack"
    BACKUP_DIR="/opt/app-stack/backups"
    BACKUP_RETENTION_DAYS="7"
    ```

4. **Update the Docker Compose file**

    Edit `/opt/app-stack/docker-compose.yml` to match your app and production requirements (image, ports, volumes, etc.).

5. **Start the app stack**

    The systemd service will start the stack on the next reboot. To start immediately:

    ```bash
    sudo /opt/app-stack/start-app-stack.sh
    ```

    Or restart the service:

    ```bash
    sudo systemctl restart app-stack.service
    ```

6. **Verify deployment**

    - Check service status:

        ```bash
        sudo systemctl status app-stack.service
        ```

    - View logs:

        ```bash
        cd /opt/app-stack
        docker compose logs -f
        ```

    - Access your app at `http://<vm-ip>:8080`

## Configuration

- Ensure `.env` and `docker-compose.yml` are consistent and reflect production values.
- Restrict permissions on `.env` (`chmod 600 /opt/app-stack/.env`).
- Use strong passwords and consider external secret management for sensitive values.
- Set up your local registry and push your app image before deployment.

## Initial Setup

- After first deployment, test application endpoints and database connectivity.
- Schedule regular extraction of backup files to external media or remote storage.
- Monitor resource usage and logs for early detection of issues.

## References

- [App Stack Role Documentation](../../scripts/app-stack/README.md)
- [Docker Registry Playbook](docker-registry.md)
- [Proxmox VM Template Playbook](proxmox-vm-template.md)
- [Server Remote Access Playbook](server-remote-access.md)
