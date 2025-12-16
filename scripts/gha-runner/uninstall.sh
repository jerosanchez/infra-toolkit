#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
UNINSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/uninstall-role.sh"
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
    if [ -f /opt/$SERVER_ROLE/.env ]; then
        source "/opt/$SERVER_ROLE/.env"
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

remove_existing_container() {
  if docker ps -a --format '{{.Names}}' | grep -Eq "^${RUNNER_NAME}$"; then
    echo "Stopping and removing existing container: $RUNNER_NAME"
    docker stop "$RUNNER_NAME"
    docker rm "$RUNNER_NAME"
  fi
}

uninstall_role() {
    bash "$UNINSTALL_ROLE_SCRIPT" "$SERVER_ROLE"
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
    remove_existing_container
    cleanup_config_dir
}

main "$@"
