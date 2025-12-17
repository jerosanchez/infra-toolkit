# Install Docker
MD_FILES := $(wildcard *.md) $(wildcard docs/**/*.md) LICENSE
SH_FILES := $(wildcard *.sh)

phony: lint

lint:
	@echo "Linting markdown files..."
	@if [ -n "$(MD_FILES)" ]; then markdownlint $(MD_FILES); else echo "No markdown files to lint."; fi
	@echo "Linting shell scripts..."
	@if [ -n "$(SH_FILES)" ]; then shellcheck $(SH_FILES); else echo "No shell scripts to lint."; fi

gha-runner:
	@echo "Installing GitHub Actions runner..."
	bash ./scripts/gha-runner/install.sh

registry:
	@echo "Installing Docker registry..."
	bash ./scripts/registry/install.sh

.PHONY: lint gha-runner

