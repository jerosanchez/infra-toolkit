# GitHub Self-Hosted Runner Playbook

Setting up a self-hosted GitHub Actions runner in your home lab should be as close to "launch and forget" as possible. After a few rounds of trial, error, and automation, here’s the playbook I use to get a reliable runner humming along in Docker—no manual token wrangling, no drama.

---

## What You’ll Need

- **Ubuntu Server 24.04 LTS** (or similar) running in your Proxmox cluster
- **Docker** installed and working (see [ubuntu-docker.md](ubuntu-docker.md) for setup)
- **jq** installed for JSON parsing
- A **GitHub Personal Access Token (PAT)** with `repo` scope (and `admin:repo_hook` for private repos)
- SSH access to your VM

---

## Step 1: Install jq

```bash
sudo apt update
sudo apt install jq
```

## Step 2: Get Your GitHub PAT

- Go to [https://github.com/settings/tokens](https://github.com/settings/tokens)
- Click **"Generate new token (classic)"** (or **"Fine-grained token"** for more control)
- Give your token a name and set an expiration date (I use 30 days for real-world discipline)
- Select the required scopes:
  - For public repos: `repo`
  - For private repos: `repo` and `admin:repo_hook`s
- Click **"Generate token"** and copy it (you won’t see it again)

---

## Step 3: Create a `.env` File for Config and Secrets

Keep your secrets out of version control! Example:

```text
GITHUB_OWNER="jerosanchez"
GITHUB_PAT=ghp_xxxYOUR_TOKEN_HERExxx
GITHUB_REPO="jerosanchez.com"
RUNNER_NAME="blog-gha-runner"
CONFIG_DIR="$HOME/github-runner"
```

---

## Step 4: Write the Launch Script

Here’s a script that does it all:

```bash
#!/bin/bash

# Load secrets from .env file in the same directory
if [ -f /home/jero/.env ]; then
  source /home/jero/.env
else
  echo "Missing .env file with secrets. Exiting."
  exit 1
fi

# Ensure the runner config directory exists
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

# Get a fresh registration token from GitHub API
REG_TOKEN=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/actions/runners/registration-token" \
  | jq -r .token)

if [ "$REG_TOKEN" == "null" ] || [ -z "$REG_TOKEN" ]; then
  echo "Failed to get registration token. Check your PAT and repo details."
  exit 1
fi

# Stop and remove existing runner container if it exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^${RUNNER_NAME}$"; then
  echo "Stopping and removing existing container: $RUNNER_NAME"
  docker stop "$RUNNER_NAME"
  docker rm "$RUNNER_NAME"
fi

# Launch the Docker runner
docker run -d --name $RUNNER_NAME \
  -v $CONFIG_DIR:/runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e RUNNER_NAME=$RUNNER_NAME \
  -e REPO_URL=https://github.com/$GITHUB_OWNER/$GITHUB_REPO \
  -e RUNNER_TOKEN=$REG_TOKEN \
  myoung34/github-runner:ubuntu-noble
```

Set executable permissions:

```bash
chmod +x ~/start-github-runner.sh
```

---

## Step 5: Create a systemd Service for Automatic Startup

To ensure your runner always starts with a fresh token after a reboot, create a systemd service to run your launch script on boot:

```bash
sudo nano /etc/systemd/system/github-runner.service
```

Paste the following (edit paths as needed):

```ini
[Unit]
Description=GitHub Actions Self-Hosted Runner
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/home/jero/start-github-runner.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

Enable the service so it runs at every boot:

```bash
sudo systemctl enable github-runner.service
```

You can start it immediately with:

```bash
sudo systemctl start github-runner.service
```

Now, every time your VM reboots, the runner will be refreshed and ready to go!

---

## Step 6: Configure Your Workflow

In your workflow YAML (e.g., `.github/workflows/deploy.yml`):

```yaml
jobs:
  build-and-deploy:
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      # ... other steps ...
```

---

## Notes & Gotchas

- **Registration tokens expire in about 1 hour.** The script always fetches a fresh one before launching the runner.
- **Restart policy is not enough!** Docker's `--restart unless-stopped` will restart the container after a reboot, but the runner will fail because the registration token will have expired. Instead, use a systemd service to run your launch script on boot—this ensures a fresh token and a working runner every time your VM restarts.
- **PAT rotation:** Set a calendar reminder to renew your PAT every 30 days (or whatever you choose).
- **Docker socket:** Mounting `/var/run/docker.sock` lets your runner build and deploy containers. For personal labs, this is fine; for production, consider security implications.
- **Scale:** You can run multiple runners (one per repo) as long as your VM has enough resources.
- **Launch and forget:** Once the runner is up, it will keep picking up jobs until you stop or remove the container (or reboot, if you use the systemd method above).

---

That’s it! You now have a self-hosted runner that’s as hands-off as it gets. If you ever need to refresh, just rerun the script. Real-world automation, with just enough discipline to keep things safe and sane.
