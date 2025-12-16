# Proxmox VM Template Playbook

Creating a VM template with cloud images allows you to quickly and reliably deploy new VMs in your Proxmox cluster. This playbook provides a clear, step-by-step process for building a reusable VM template.

**Note:** This process must be performed on each Proxmox node individually. Templates are stored locally on each node, so repeat these steps for every node where you want the template available.

**VM IDs:** VM IDs are unique across the entire cluster. Do not reuse the same VM ID on different nodes.

---

## Requirements

Before you begin, ensure you have:

- Access to your Proxmox node (SSH and web UI)
- The latest [Ubuntu LTS minimal cloud image URL](https://cloud-images.ubuntu.com/minimal/releases/)
- An VM ID range convention for templates (e.g., in the 9xx range)
- A naming convention for templates (e.g., `<distro>-<version>-tmpl`)

---

## Creating the Base VM

1. In the Proxmox web UI, create a new VM:
   - **Node:** Select your target node (e.g., `pve1`)
   - **VM ID:** Choose an unused ID (e.g., `910`)
   - **Name:** Use your naming convention (e.g., `ubuntu-2404-tmpl`)
2. In the OS section, select **Do not use any media**.
3. Under System, enable **Qemu Agent**.
4. For Disks, remove the default SCSI disk (you will add your own).
5. Leave CPU and Memory at defaults unless you have specific requirements.

Do not start the VM when finished.

---

## Setting Up Cloud-Init

1. In the Proxmox UI, select the VM and go to **Hardware**.
2. Add a **CloudInit Drive** (IDE bus, `local-lvm` storage).
3. In the **Cloud-Init** menu, configure:
   - **User:** Set your preferred username
   - **Password:** Set a secure password
   - **SSH public key:** Leave blank or add as needed
   - **IP Config:** Set to DHCP
   - Click **Regenerate Image**

---

## Importing the Cloud Image

1. SSH into your Proxmox node as root.
2. Run the following commands (replace `<VMID>` as needed):

   ```bash
   # Set up serial console and VGA
   qm set <VMID> --serial0 socket --vga serial0

   # Download the latest Ubuntu LTS minimal cloud image
   # This is the latest URL at the time of writing, change as required
   wget https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img

   # Rename and convert the image
   mv ubuntu-24.04-minimal-cloudimg-amd64.img ubuntu-24.04.qcow2

   # Resize the image as needed
   qemu-img resize ubuntu-24.04.qcow2 16G

   # Import the disk into Proxmox
   qm importdisk <VMID> ubuntu-24.04.qcow2 local-lvm
   ```

3. In the Proxmox UI, select **Hardware > Unused Disk 0**.
4. Enable **Discard** (for SSDs), click **Advanced** and enable **SSD emulation**, then add the disk.

---

## Final Configuration

1. In **Options**, enable **Start at boot**.
2. Set the **Boot Order** so the imported disk is enabled and second in the list (leave CD-ROM first if needed).

---

## Convert to Template

1. Right-click the VM and select **Convert to template**.

Your VM template is now ready for use on this node.

---

## Next Steps

- Repeat this process on each node where you want the template available.
- For more details on naming, password management, and networking, refer to your internal guides or the [Proxmox documentation](https://pve.proxmox.com/wiki/Main_Page).

This template provides a consistent and efficient starting point for new VMs in your Proxmox environment.
