# Docker on Ubuntu Server Playbook

This playbook provides a clear, step-by-step process for installing Docker on a fresh Ubuntu Server. Follow these instructions to set up Docker quickly and reliably, especially if your server is running as a VM in Proxmox.

---

## Requirements

Before you begin, ensure you have:

- **Ubuntu Server 24.04 LTS** running (preferably in a Proxmox VM)
- **SSH access** to your server
- A user account with sudo privileges

---

## Installation Steps

1. **Update package lists:**

    ```bash
    sudo apt update
    ```

2. **Install prerequisites:**

    ```bash
    sudo apt -y install ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    ```

3. **Add Docker’s official repository:**

    ```bash
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    ```

4. **Install Docker Engine and related packages:**

    ```bash
    sudo apt -y install docker-ce docker-ce-cli containerd.io
    ```

5. **Add your user to the docker group:**

    ```bash
    sudo usermod -aG docker $USER
    ```

6. **Reboot the server:**

    ```bash
    sudo reboot
    ```

---

## Post-Installation Verification

After rebooting, verify Docker is installed and working:

```bash
docker --version
```

If you see a version string, Docker is installed correctly.

---

## Tips & Troubleshooting

- If your user cannot run `docker` without `sudo`, ensure you are in the `docker` group and have logged out/in or rebooted.
- For more details, refer to the [official Docker documentation](https://docs.docker.com/engine/install/ubuntu/).

---

This playbook helps you set up Docker on Ubuntu Server efficiently and consistently.
