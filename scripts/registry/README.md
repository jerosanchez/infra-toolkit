# Docker Registry Role Setup

This directory contains automation scripts to deploy and manage a private Docker registry on Linux servers. The scripts simplify the process of assigning the "registry" role to a newly provisioned VM, allowing you to quickly enable or remove a private container registry as needed.

---

## Purpose

These scripts automate the complete lifecycle of a Docker registry service:

- Install required dependencies (Docker)
- Configure the registry using environment variables
- Deploy the registry as a Docker container
- Create a systemd service for easy management and optional automatic startup after reboots
- Provide clean uninstallation to repurpose the server for other roles

---

## Components

The directory contains the following files:

- **install.sh**: Main installation script that orchestrates the entire setup process
- **uninstall.sh**: Cleanup script that removes all registry components and configuration
- **start-registry.sh**: Registry startup script that launches the Docker container
- **cleanup-registry.sh**: Helper script to remove old images from the registry based on age
- **.env.example**: Template file containing required environment variables

---

## Prerequisites

- A Linux server with Ubuntu (recommended: Ubuntu Noble or later)
- Root or sudo access
- Network access to Docker Hub

---

## Installation

Run the installation from the root of the infra-toolkit repository:

```bash
make registry
```

This command will:

1. Check for Docker installation and install it if missing (requires reboot)
2. Copy all necessary files to `/opt/registry/`
3. Create a systemd service named `registry.service`
4. Enable the service for automatic startup (the service is enabled by default)
5. To start the registry, either reboot the server (the service will start automatically), or start it manually if you don't want to reboot

After installation, configure your registry settings:

```bash
sudo vim /opt/registry/.env
```

Fill in the required values:

```text
REGISTRY_CONTAINER_NAME="my-registry"
REGISTRY_PORT="5000"
REGISTRY_DATA_DIR="/opt/registry/data"
```

To start the registry service, you have two options:

- **Reboot the server:** The registry service will start automatically on boot.
- **Start manually without rebooting:**

```bash
sudo systemctl start registry.service
```

---

## Automated Registry Cleanup

To prevent the registry from filling up with old images, a cleanup script is provided and scheduled to run daily at 2am via cron. This script removes images older than 7 days by default.

- The script is copied to `/opt/registry/cleanup-registry.sh` during installation.
- The following cron job is automatically added:

```cron
0 2 * * * /opt/registry/cleanup-registry.sh 7 >/var/log/registry-cleanup.log 2>&1
```

You can adjust the retention period by editing the cron job or running the script manually with a different argument.

To run the cleanup manually:

```bash
sudo /opt/registry/cleanup-registry.sh 14
```

This would remove images older than 14 days.

---

## Uninstallation

To remove the registry and clean up the server:

```bash
make registry-rm
```

This will:

1. Stop and remove the Docker container
2. Remove the systemd service
3. Delete all files from `/opt/registry/`
4. Remove the registry data directory (all images stored in the registry will be deleted)

The server will be ready to be assigned a different role or decommissioned.

---

## Environment Variables

The `.env` file must define the following variables:

- `REGISTRY_CONTAINER_NAME`: Name for the Docker container (e.g., `my-registry`)
- `REGISTRY_PORT`: Port to expose the registry (e.g., `5000`)
- `REGISTRY_DATA_DIR`: Directory for registry data (e.g., `/opt/registry/data`)

---

## Security Notes

- This setup runs a basic, unauthenticated registry. For production, consider enabling authentication and TLS.
- Ensure your firewall allows access to the registry port only from trusted sources.

---

## Review & Linting

- All scripts follow [ShellCheck](https://www.shellcheck.net/) and markdown guidelines for compatibility with markdown linters (e.g., `markdownlint`).
- Review and test scripts before use in production environments.

---

By following these scripts, you can quickly assign or remove the Docker registry role on any VM in your infrastructure.
