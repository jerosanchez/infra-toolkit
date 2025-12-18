# Install Docker
MD_FILES := $(shell find . -type f -name '*.md') LICENSE
SH_FILES := $(shell find . -type f -name '*.sh')

phony: lint

lint:
	@echo "Linting markdown files..."
	@if [ -n "$(MD_FILES)" ]; then markdownlint $(MD_FILES); else echo "No markdown files to lint."; fi
	@echo "Linting shell scripts..."
	@if [ -n "$(SH_FILES)" ]; then shellcheck -x -e SC1091 $(SH_FILES); else echo "No shell scripts to lint."; fi

gha-runner:
	@echo "Installing GitHub Actions runner role..."
	bash ./scripts/gha-runner/install.sh

registry:
	@echo "Installing Docker registry role..."
	bash ./scripts/registry/install.sh

registry-rm:
	bash ./scripts/registry/uninstall.sh

.PHONY: lint gha-runner registry registry-rm
