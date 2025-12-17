<!-- markdownlint-disable MD041 -->
<!-- GitHub Actions Badges -->
[![Lint](https://github.com/jerosanchez/infra-toolkit/actions/workflows/lint.yml/badge.svg)](https://github.com/jerosanchez/infra-toolkit/actions/workflows/lint.yml)
[![Beta](https://img.shields.io/badge/status-beta-orange)](https://shields.io/)

> **⚠️ WARNING: This project is still work in progress, not suited for production use yet.**

# README

This project is a collection of scripts and documentation (playbooks) to help set up and manage a local homelab infrastructure for personal projects.

## Getting Started

To get started with infra-toolkit on a new VM:

First clone the repository:

```bash
git clone https://github.com/jerosanchez/infra-toolkit.git
cd infra-toolkit
```

Then choose and install a role:

This toolkit uses a role-based approach to automate server setup. Each role configures a server for a specific purpose.Currently, the following role is available:

- **GHA self-hosted runner**: Installs and manages a GitHub Actions runner in a Docker container, with automated setup and systemd integration. See [scripts/gha-runner/README.md](scripts/gha-runner/README.md) for full instructions.

Then follow the prompts and documentation to configure your GitHub credentials and start the runner.
