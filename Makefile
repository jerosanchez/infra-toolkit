MD_FILES := $(wildcard *.md) LICENSE
SH_FILES := $(wildcard *.sh)

phony: lint

lint:
	@echo "Linting markdown files..."
	@if [ -n "$(MD_FILES)" ]; then markdownlint $(MD_FILES); else echo "No markdown files to lint."; fi
	@echo "Linting shell scripts..."
	@if [ -n "$(SH_FILES)" ]; then shellcheck $(SH_FILES); else echo "No shell scripts to lint."; fi

.PHONY: lint
