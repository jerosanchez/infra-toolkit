
# GHA Self-Hosted Runner Playbook

Setting up a self-hosted GitHub Actions runner in your home lab is now fully automated using the scripts provided in the `infra-toolkit/scripts/gha-runner` folder. This playbook summarizes the process and highlights the only manual step required: generating a GitHub Personal Access Token (PAT) with the correct permissions.

---

## Prerequisites

- **Ubuntu Server 24.04 LTS** (or similar) running in your Proxmox cluster
- SSH access to your VM
- A **GitHub Personal Access Token (PAT)** with the required scopes (see below)

---

## Step 1: Generate a GitHub PAT

You will need a Personal Access Token (PAT) to register your runner with GitHub:

1. Go to [https://github.com/settings/tokens](https://github.com/settings/tokens)
2. Click **"Generate new token (classic)"** (or **"Fine-grained token"** for more control)
3. Give your token a name and set an expiration date (e.g., 30 days)
4. Select the required scopes:
   - For public repos: `repo`
   - For private repos: `repo` and `admin:repo_hook`
5. Click **"Generate token"** and copy it (you won’t see it again)

---

## Step 2: Automated Installation & Management

All other steps—installing dependencies, configuring the runner, setting up systemd, and managing the runner lifecycle—are fully automated.

**Follow the instructions in [`infra-toolkit/scripts/gha-runner/README.md`](../../scripts/gha-runner/README.md) to:**

- Install the runner with a single command (`make gha-runner`)
- Configure your `.env` file with your GitHub credentials and PAT
- Start, stop, or uninstall the runner cleanly
- Understand how the automation works under the hood

---

## Step 3: Configure Your Workflow

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

## Notes

- The runner setup, registration, and service management are handled by the provided scripts—no need to manually install Docker, jq, or write launch/systemd scripts.
- Registration tokens are automatically fetched and refreshed as needed by the automation.
- For troubleshooting, security, and advanced configuration, see the [`README.md`](../../scripts/gha-runner/README.md) in the scripts folder.
