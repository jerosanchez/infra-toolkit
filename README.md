<!-- markdownlint-disable MD041 -->
<!-- GitHub Actions Badges -->
[![Lint](https://github.com/jerosanchez/infra-toolkit/actions/workflows/lint.yml/badge.svg)](https://github.com/jerosanchez/infra-toolkit/actions/workflows/lint.yml)
[![Beta](https://img.shields.io/badge/status-beta-orange)](https://shields.io/)

> **⚠️ WARNING: This project is still work in progress, not suited for production use.**

# README

This project is a collection of scripts and documentation (playbooks) to help set up and manage a local homelab infrastructure for personal projects.

## Getting Started

Read the playbooks located in [docs/playbooks/](docs/playbooks/) to setup a Proxmox-based infrastructure.

Once you have the infrastructure ready, you can spin up new VMs and assign them a role using this toolkit as follows:

First clone the repository:

```bash
git clone https://github.com/jerosanchez/infra-toolkit.git
cd infra-toolkit
```

Then choose and install a rol using `make`:

- **GHA self-hosted runner**: Run `make gha-runner`. Deploys a GitHub Actions self-hosted runner for CI/CD workflows on your infrastructure.

See [scripts/gha-runner/README.md](scripts/gha-runner/README.md) for details.

- **Docker registry**: Run `make registry`. Deploys a private Docker registry for storing and distributing container images locally, with automated cleanup and service management.

See [scripts/registry/README.md](scripts/registry/README.md) for details.

- **App stack (Spring Boot + PostgreSQL)**: Run `make app-stack`. Deploys a modular monolith application and database using Docker Compose, with automated backup and cleanup scripts.

See [scripts/app-stack/README.md](scripts/app-stack/README.md) for details.

## Future Improvements

- Add roles for production and staging environments to support more advanced deployment scenarios.
- Provide Terraform and/or Ansible scripts to automate:
  - Creation of Proxmox VM templates
  - Spinning up VMs from templates
  - Full infrastructure provisioning and configuration
- Expand playbooks and scripts for additional homelab and cloud-native use cases.
