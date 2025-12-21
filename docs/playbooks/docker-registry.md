# Local Docker Registry Playbook

Setting up a private Docker registry in your home lab is now fully automated using the scripts provided in the `infra-toolkit/scripts/registry` folder. This playbook summarizes the process and highlights the only manual step required: configuring your environment variables.

---

## Prerequisites

- **Ubuntu Server 24.04 LTS** (or similar) running in your Proxmox cluster
- SSH access to your VM
- Docker and `jq` installed (handled by automation)

---

## Step 1: Automated Installation & Manual Start

All steps—installing dependencies, configuring the registry, and setting up persistence—are fully automated. **However, starting the registry service is now a manual step after installation.**

**Follow the instructions in [`infra-toolkit/scripts/registry/README.md`](../../scripts/registry/README.md) to:**

- Install the registry with a single command (`make registry`)
- Configure your `.env` file.
- Start the registry manually after installation** (see the README for the exact command)
- Understand how the automation works under the hood

---

## Step 2: Push Images to Your Local Registry

To push Docker images to your local registry from a self-hosted runner or local machine, update your workflow YAML as follows:

**Important:** If your registry is running without HTTPS (plain HTTP), Docker will refuse to push images unless you configure it to allow insecure registries. On the machine where you build and push images, add the following to `/etc/docker/daemon.json`:

```json
{
  "insecure-registries": ["registry.local:5000"]
}
```

Then restart Docker:

```bash
sudo systemctl restart docker
```

This allows Docker to push images to your local registry over HTTP. If you skip this, you may see errors like:

`server gave HTTP response to HTTPS client`

1. **Tag your image for the local registry:**

    ```yaml
    - name: Build Docker image
      run: |
        docker build -t registry.local:5000/my-app:${{ github.sha }} .
    ```

2. **Push the image to the local registry:**

    ```yaml
    - name: Push image to local registry
      run: |
        docker push registry.local:5000/my-app:${{ github.sha }}
    ```

3. **(Optional) Use the image in later steps or deployments:**

    - Reference `registry.local:5000/my-app:${{ github.sha }}` in your deployment scripts or Kubernetes manifests.

---

## Notes

- The registry setup, persistence, and service management are handled by the provided scripts—no need to manually create systemd services or manage containers.
- Automated cleanup of old images is available via the included scripts (see the README for scheduling options).
- No authentication is required for a default local registry, but you can enable it for extra security.
- Make sure your registry is reachable from your runners (check firewall rules and network settings).
- For troubleshooting and advanced configuration, see the [`README.md`](../../scripts/registry/README.md) in the scripts folder.
