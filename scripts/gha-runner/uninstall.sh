#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
UNINSTALL_ROLE_SCRIPT="$SCRIPTS_DIR/../shared/uninstall.sh"
SERVER_ROLE="gha-runner"

print_usage() {
    echo "Usage: $0"
}

parse_args() {
    if [ "$#" -ne 0 ]; then
        print_usage
        exit 1
    fi
}

load_env() {
    if [ -f /home/jero/.env ]; then
        source /home/jero/.env
    fi
}

run_pre_checks() {
    if [ ! -x "$UNINSTALL_ROLE_SCRIPT" ]; then
        echo "Error: Shared uninstall script not found or not executable: $UNINSTALL_ROLE_SCRIPT"
        exit 1
    fi
    if [ -z "${CONFIG_DIR:-}" ]; then
        echo "Error: CONFIG_DIR is not set. Please check your .env file."
        exit 1
    fi
}

uninstall_role() {
    "$UNINSTALL_ROLE_SCRIPT" "$SERVER_ROLE"
}

cleanup_config_dir() {
    if [ -n "${CONFIG_DIR:-}" ] && [ -d "$CONFIG_DIR" ]; then
        echo "Removing config directory: $CONFIG_DIR"
        rm -rf "$CONFIG_DIR"
    fi
}

main() {
    parse_args "$@"
    load_env
    run_pre_checks
    uninstall_role
    cleanup_config_dir
}

main "$@"
