<!-- markdownlint-disable MD041 -->
<!-- GitHub Actions Badges -->
[![Lint](https://github.com/jerosanchez/infra-toolkit/actions/workflows/lint.yml/badge.svg)](https://github.com/jerosanchez/infra-toolkit/actions/workflows/lint.yml)
[![Beta](https://img.shields.io/badge/status-beta-orange)](https://shields.io/)

> **⚠️ WARNING: This project is still work in progress, not suited for production use.**

# README

This project is a collection of scripts and documentation (playbooks) to help set up and manage a local homelab infrastructure for personal projects.

## Getting Started

To get started with infra-toolkit on a new VM:

First clone the repository:

```bash
git clone https://github.com/jerosanchez/infra-toolkit.git
cd infra-toolkit
```

Then choose and install a rol using `make`.

This toolkit uses a role-based approach to automate server setup. Each role configures a server for a specific purpose. Currently, the following roles are available:

- **GHA self-hosted runner**: Run `make gha-runner`. See [scripts/gha-runner/README.md](scripts/gha-runner/README.md) for details.
- **Docker registry**: Run `make registry`. See [scripts/registry/README.md](scripts/registry/README.md) for details.

## Playbooks and Documentation

This repository includes a set of playbooks located in [docs/playbooks/](docs/playbooks/) that provide detailed, step-by-step instructions for:

- Understanding and using each role’s scripts (e.g., GitHub Actions runner, Docker registry)
- Setting up and managing a Proxmox-based infrastructure, including:
  - Proxmox node setup
  - Proxmox cluster creation
  - Creating VM templates
  - Spinning up VMs from templates
  - Server remote access
  - Docker on Ubuntu

Refer to the relevant playbook for comprehensive guidance on each topic:

- [gha-self-hosted-runner.md](docs/playbooks/gha-self-hosted-runner.md): GitHub Actions runner setup
- [docker-registry.md](docs/playbooks/docker-registry.md): Docker registry setup
- [proxmox-node.md](docs/playbooks/proxmox-node.md): Proxmox node setup
- [proxmox-cluster.md](docs/playbooks/proxmox-cluster.md): Proxmox cluster setup
- [proxmox-vm-template.md](docs/playbooks/proxmox-vm-template.md): VM template creation
- [proxomox-vm-from-tmpl.md](docs/playbooks/proxomox-vm-from-tmpl.md): Spinning up VMs from templates
- [server-remote-access.md](docs/playbooks/server-remote-access.md): Remote access setup
- [ubuntu-docker.md](docs/playbooks/ubuntu-docker.md): Docker installation on Ubuntu
