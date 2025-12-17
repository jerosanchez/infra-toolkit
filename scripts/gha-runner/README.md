# GitHub Actions Self-Hosted Runner Setup

This directory contains automation scripts to deploy and manage GitHub Actions (GHA) self-hosted runners on Linux servers. The scripts simplify the process of assigning the "GHA runner" role to a newly provisioned VM, allowing you to quickly scale your CI/CD infrastructure.

## Purpose

These scripts automate the complete lifecycle of a GHA self-hosted runner:

- Install required dependencies (Docker, jq)
- Configure the runner using environment variables
- Deploy the runner as a Docker container
- Create a systemd service for automatic startup after reboots
- Provide clean uninstallation to repurpose the server for other roles

---

## Components

The directory contains the following files:

- **install.sh**: Main installation script that orchestrates the entire setup process
- **uninstall.sh**: Cleanup script that removes all runner components and configuration
- **start-gha-runner.sh**: Runner startup script that fetches registration tokens and launches the Docker container
- **.env.example**: Template file containing required environment variables

---

## Prerequisites

- A Linux server with Ubuntu (recommended: Ubuntu Noble or later)
- Root or sudo access
- Active GitHub Personal Access Token (PAT) with `repo` and `admin:org` scopes
- Network access to GitHub API and Docker Hub

---

## Installation

Run the installation from the root of the infra-toolkit repository:

```bash
make gha-runner
```

This command will:

1. Check for Docker installation and install it if missing (requires reboot)
2. Install `jq` for JSON processing
3. Copy all necessary files to `/opt/gha-runner/`
4. Create a systemd service named `gha-runner.service`
5. Enable the service for automatic startup

After installation, configure your GitHub credentials:

```bash
sudo vim /opt/gha-runner/.env
```

Fill in the required values:

```bash
GITHUB_OWNER="your_github_username"
GITHUB_PAT="ghp_xxxYOUR_TOKEN_HERExxx"
GITHUB_REPO="your_repository_name"
RUNNER_NAME="gha-runner"
CONFIG_DIR="$HOME/github-runner"
```

Start the runner service:

```bash
sudo systemctl start gha-runner.service
```

Check the service status:

```bash
sudo systemctl status gha-runner.service
```

---

## Uninstallation

To remove the GHA runner and clean up the server:

```bash
cd ~/infra-toolkit/scripts/gha-runner
sudo ./uninstall.sh
```

This will:

1. Stop and remove the Docker container
2. Remove the systemd service
3. Delete all files from `/opt/gha-runner/`
4. Clean up the runner configuration directory

The server will be ready to be assigned a different role or decommissioned.

---

## How It Works

### Installation Process

The installation follows a multi-stage process leveraging shared utility scripts:

1. **install.sh** serves as the entry point and:
   - Validates the presence of required shared scripts
   - Calls `install-docker.sh` if Docker is not installed
   - Installs `jq` via apt-get
   - Delegates role installation to `install-role.sh`

2. **install-role.sh** (shared utility) handles the generic role assignment:
   - Copies `start-gha-runner.sh` to `/opt/gha-runner/`
   - Creates `/opt/gha-runner/.env` from `.env.example`
   - Sets proper file permissions
   - Invokes `create-service.sh` to configure systemd

3. **create-service.sh** (shared utility) creates the systemd service:
   - Generates a service unit file at `/etc/systemd/system/gha-runner.service`
   - Configures the service to run after Docker is available
   - Sets the service type as `oneshot` with `RemainAfterExit=true`
   - Enables the service for automatic startup

### Runtime Execution

When the systemd service starts (at boot or manually), it executes **start-gha-runner.sh**:

1. Loads environment variables from `/opt/gha-runner/.env`
2. Requests a registration token from the GitHub API using the PAT
3. Removes any existing runner container with the same name
4. Launches a new Docker container using the `myoung34/github-runner:ubuntu-noble` image
5. Mounts the Docker socket to allow the runner to execute Docker commands
6. Registers the runner with your GitHub repository

The runner container automatically connects to GitHub and begins accepting workflow jobs.

### Uninstallation Process

The cleanup process ensures complete removal:

1. **uninstall.sh** orchestrates the removal:
   - Loads environment variables to identify resources
   - Stops and removes the Docker container
   - Calls `uninstall-role.sh` for generic cleanup
   - Removes the runner configuration directory

2. **uninstall-role.sh** (shared utility) performs role-agnostic cleanup:
   - Invokes `remove-service.sh` to handle systemd cleanup
   - Deletes the `/opt/gha-runner/` directory

3. **remove-service.sh** (shared utility) cleans up the systemd service:
   - Stops and disables the service
   - Removes the service unit file
   - Reloads the systemd daemon

---

## Modifying the Scripts

### Changing the Docker Image

To use a different GitHub runner Docker image, edit **start-gha-runner.sh** and modify the `docker run` command:

```bash
docker run -d --name $RUNNER_NAME \
  -v $CONFIG_DIR:/runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e RUNNER_NAME=$RUNNER_NAME \
  -e REPO_URL=https://github.com/$GITHUB_OWNER/$GITHUB_REPO \
  -e RUNNER_TOKEN=$REG_TOKEN \
  your-custom-image:tag
```

### Adding Additional Configuration

To pass additional environment variables to the runner container:

1. Add new variables to `.env.example`
2. Update **start-gha-runner.sh** to include them in the `docker run` command with `-e` flags

### Adjusting Service Behavior

To modify how the systemd service operates, edit the **create-service.sh** script in the shared directory. Common modifications include:

- Changing `Type=oneshot` to `Type=simple` for long-running processes
- Adding `Restart=always` for automatic restart on failure
- Modifying `After=` to add additional service dependencies

---

## Troubleshooting

View service logs:

```bash
sudo journalctl -u gha-runner.service -f
```

Check Docker container logs:

```bash
docker logs gha-runner
```

Verify the runner is registered on GitHub:

- Navigate to your repository settings
- Go to Actions > Runners
- Look for your runner name in the list

---

## Security Considerations

- The `.env` file contains sensitive credentials (GitHub PAT)
- Ensure `/opt/gha-runner/.env` has restrictive permissions (644 or stricter)
- Use a PAT with minimal required scopes
- Consider using GitHub App tokens for enhanced security in production environments
- The runner has access to the Docker socket, which provides elevated privileges

---

## Additional Resources

- [GHA Self-Hosted Runner Playbook](../../docs/playbooks/gha-self-hosted-runner.md)
- [GitHub Actions Self-Hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [myoung34/github-runner Docker Image](https://github.com/myoung34/docker-github-actions-runner)
- [Systemd Service Configuration](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
