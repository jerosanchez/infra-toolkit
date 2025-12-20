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

gha-runner-rm:
	bash ./scripts/gha-runner/uninstall.sh

registry:
	@echo "Installing Docker registry role..."
	bash ./scripts/registry/install.sh

registry-rm:
	bash ./scripts/registry/uninstall.sh

app-stack:
	@echo "Installing application stack role..."
	bash ./scripts/app-stack/install.sh

app-stack-rm:
	bash ./scripts/app-stack/uninstall.sh

.PHONY: lint gha-runner gha-runner-rm registry registry-rm app-stack app-stack-rm
