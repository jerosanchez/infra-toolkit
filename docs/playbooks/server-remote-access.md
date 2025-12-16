# Server Remote Access Playbook

SSH keys provide secure, convenient, and passwordless access to your servers. This playbook explains how to generate, manage, and use SSH keys for accessing your homelab or production servers.

---

## What Are SSH Keys?

SSH keys are a pair of cryptographic files: a **private key** (kept securely on your computer) and a **public key** (shared with servers you want to access). When you connect, your computer proves it has the private key, and the server checks your public key—no password required.

**Benefits:**

- **Security:** Stronger than passwords.
- **Convenience:** One key can access multiple servers.
- **Automation:** Enables secure, unattended connections for scripts and tools.

---

## Generating an SSH Key

To create a new SSH key pair, run:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

- Accept the default file location (`~/.ssh/id_ed25519`) or specify a custom path.
- Set a passphrase for extra security (optional, but recommended).
- This creates:
  - `~/.ssh/id_ed25519` (private key—keep safe)
  - `~/.ssh/id_ed25519.pub` (public key—share with servers)

Set correct permissions:

```bash
chmod 600 ~/.ssh/id_ed25519
```

Never share your private key. Only the `.pub` file should be copied to servers.

---

## Adding Your Public Key to a Server

To enable key-based access, add your public key to the server’s `~/.ssh/authorized_keys` file.

- **With Cloud-Init:** Paste your public key into the Cloud-Init config before first boot.
- **Manually:** Use:

  ```bash
  ssh-copy-id -i ~/.ssh/id_ed25519.pub username@server-ip
  ```

  Or copy the contents of your `.pub` file into `~/.ssh/authorized_keys` on the server.

---

## Managing Multiple SSH Keys

If you use multiple keys, specify which key to use:

```bash
ssh -i ~/.ssh/my_homelab_key username@server
```

To simplify, use the `~/.ssh/config` file:

```text
Host registry k3s-n1 gha-runner
    User jero
    IdentityFile ~/.ssh/jero@sirius

Host my-vps
    User jero
    IdentityFile ~/.ssh/id_ed25519
```

Now you can connect with `ssh registry` and the correct key is used automatically.

---

## Making Hostnames Easier

Add your servers’ IPs and hostnames to your local `/etc/hosts` file:

```text
192.168.1.123   registry
192.168.1.124   gha-runner
```

This allows you to SSH using hostnames instead of IP addresses.

---

## Tips and Troubleshooting

- Always use the private key (no `.pub`) with `ssh -i`.
- If you get `Permission denied (publickey)`:
  - Check the username.
  - Ensure the public key is in `authorized_keys`.
  - Verify private key permissions.
- If your private key is compromised, generate a new one and update your servers.

This playbook helps you set up secure, efficient, and reliable remote access to your servers.
