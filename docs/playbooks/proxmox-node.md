# Proxmox Node Playbook

Setting up a Proxmox node is a straightforward process when you follow the right steps. This playbook outlines the essential requirements and procedures to get your node running efficiently and reliably.

---

## Requirements

Before starting the installation, ensure you have the following:

- 64-bit CPU with virtualization support (Intel VT-x or AMD-V)
- At least 1GB RAM (4GB or more recommended)
- SSD or other fast storage
- Wired network interface (WiFi is not supported for management)
- USB stick with [Ventoy](https://www.ventoy.net/) and the latest Proxmox VE ISO
- Monitor, keyboard, and mouse for initial setup

---

## Installation: From USB to First Boot

1. Connect your prepared USB stick and boot the system.
2. Select the Proxmox ISO from the Ventoy menu and start the graphical installer.
3. Accept the EULA, select the target disk, and set your locale (e.g., Spain, Europe/Madrid, U.S. English).
4. Choose a strong password and provide your email address (e.g., `infra@jerosanchez.com`).
5. Select your wired network interface (typically `nic0`), set the hostname (FQDN, e.g., `pve1.jerosanchez.com`), assign a static IP (e.g., `192.168.1.11/24`), and configure gateway and DNS.
6. Start the installation. When complete, remove the USB stick and reboot.
7. Note the management URL displayed (e.g., `https://192.168.1.11:8006`).

---

## First Login and Post-Install Steps

1. SSH into the node as root using the password set during installation.
2. (Optional) Add a friendly hostname entry to your `/etc/hosts` file for easier access.
3. Access the Proxmox web interface using the management URL. Accept the SSL warning if prompted.
4. Update your node immediately:
   - In the Proxmox UI, select your node, go to `Updates`, and click `Upgrade` (runs `apt update && apt upgrade` under the hood).
   - Refresh the UI after updates. Ignore any TASK ERROR related to support license if you do not have one.
   - Reboot the node from the UI to apply updates.

---

## Verification and Next Steps

- Confirm SSH access and verify the web UI is reachable.
- Disconnect the monitor, mouse, and keyboard; the node is now ready for headless operation.
- For troubleshooting or further configuration, consult the official [Proxmox documentation](https://pve.proxmox.com/wiki/Main_Page).

This playbook provides a reliable foundation for your Proxmox environment. Proceed with clustering or VM deployment as needed.
