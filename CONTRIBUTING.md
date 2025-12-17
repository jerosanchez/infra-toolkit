# Contributing to infra-toolkit

Thank you for your interest in contributing!

> **Note:** The installation steps below are aimed at Debian-based Linux systems (such as Ubuntu) as an example. If you are using a different operating system, please follow the appropriate instructions for your platform to install Node.js, npm, and other dependencies.

## Prerequisites

To contribute and check code quality, you need:

- Node.js
- npm (Node.js package manager)
- markdownlint-cli (Markdown linter for Markdown files)
- ShellCheck (linter for shell scripts)
- GNU Make

## Installation Steps

### 1. Install Node.js and npm

On most Linux systems, run:

```bash
sudo apt update
sudo apt install nodejs npm
```

### 2. Install markdownlint-cli

After Node.js and npm are installed, run:

```bash
sudo npm install -g markdownlint-cli
```

### 3. Install ShellCheck

To install the shell script linter, run:

```bash
sudo apt install shellcheck
```

### 4. Verify Installation

Check that everything is installed:

```bash
node -v
npm -v
markdownlint --version
shellcheck --version
make --version
```

## Linting Files

A `Makefile` is provided with a `lint` target. To check all supported files for lint issues, run:

```bash
make lint
```

This will use:

- `markdownlint` to check all Markdown files (`*.md` and `LICENSE`)
- `shellcheck` to check all shell scripts (`*.sh`)

## Contributing Guidelines

Please follow these common practices when contributing to this project:

- **Issues:**  
  - Search existing issues before opening a new one to avoid duplicates.
  - Provide a clear and descriptive title and summary.
  - Include steps to reproduce, expected behavior, and relevant environment details.

- **Pull Requests:**  
  - Fork the repository and create your branch from `main`.
  - Write clear, concise commit messages.
  - Ensure your code passes all linting and tests before submitting (see above).
  - Reference related issues in your PR description (e.g., "Fixes #123").
  - Keep PRs focused and minimal—avoid mixing unrelated changes.
  - Be responsive to review feedback and update your PR as needed.

- **Code Style:**  
  - Follow the guidelines in `docs/agents/` for markdown, bash scripts, and Makefiles.
  - Add comments where helpful for maintainability.

- **Discussions:**  
  - Use issues or PR comments for questions, suggestions, or feedback.

Thank you for helping improve infra-toolkit!

## Need Help?

If you encounter any issues, please open an issue or ask for help in the repository.
