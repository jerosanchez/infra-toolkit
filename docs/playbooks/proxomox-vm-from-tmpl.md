# Proxmox VM Setup from Template Playbook

Deploying a new VM from a template streamlines your workflow and ensures consistency across your infrastructure. This playbook provides clear, step-by-step instructions for spinning up a ready-to-use server from a VM template.

---

## Requirements

Before you begin, ensure you have:

- A Proxmox VM template available (e.g., `ubuntu-2404-tmpl`)
- A naming convention and VM ID scheme for your environment (e.g., `1xx` for node 1, `2xx` for node 2)
- An SSH public key generated on your local machine for secure access

---

## Creating a VM from a Template

1. In the Proxmox web UI, right-click your chosen template and select **Clone**.
2. Fill in the required fields:
   - **Target node:** Where the VM will reside (e.g., `pve1`, `pve2`)
   - **VM ID:** Choose a unique ID (e.g., `100`, `201`)
   - **Name:** Assign a descriptive name (e.g., `gha-runner`, `registry`)
   - **Mode:** Select `Full Clone`
   - **Target Storage:** Optional, select if needed
3. Click **Clone** to create the VM.

---

## Configuration: Cloud-Init and First Boot

1. Before starting the VM, configure Cloud-Init:
   - Select the new VM in the Proxmox UI.
   - Go to the **Cloud-Init** tab.
   - Paste your SSH public key into the **SSH public key** field.
   - Optionally, set the username and password.
   - Click **Regenerate Image** to apply changes.
2. Start the VM.
3. Wait for the `cloud-init` process to complete before logging in. When you see `[  OK  ] Finished cloud-final.service`, SSH access is ready.

To connect:

```bash
ssh <username>@<vm-ip>
```

For more on SSH access, see the [Server Remote Access Playbook](./server-remote-access.md).

---

## Initial Setup via SSH

Once connected:

```bash
# Update the system
sudo apt update && sudo apt upgrade

# Install Qemu Guest Agent
sudo apt install qemu-guest-agent
sudo reboot

# After reboot, verify the agent is running
systemctl status qemu-guest-agent
```

For convenience, add your VM’s IP and hostname to your local `/etc/hosts` and configure your `~/.ssh/config` as described in the [Server Remote Access Playbook](server-remote-access.md).

---

## References

- For template creation, see [Proxmox VM Template Playbook](proxmox-vm-template.md).
- For naming conventions and VM ID schemes, see your internal documentation.
- For SSH access, see [Server Remote Access Playbook](server-remote-access.md).

Your VM is now ready for use—configured, updated, and integrated with your Proxmox cluster.
