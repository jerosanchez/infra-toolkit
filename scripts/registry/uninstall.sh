#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
UNINSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/uninstall-role.sh"
SERVER_ROLE="registry"

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
        # shellcheck source=/dev/null
        source "/opt/$SERVER_ROLE/.env"
    fi
}

run_pre_checks() {
    if [ ! -f "$UNINSTALL_ROLE_SCRIPT" ]; then
        echo "Error: Shared uninstall script not found or not executable: $UNINSTALL_ROLE_SCRIPT"
        exit 1
    fi
    if [ -z "${REGISTRY_CONTAINER_NAME:-}" ]; then
        echo "Error: REGISTRY_CONTAINER_NAME is not set. Please check your .env file."
        exit 1
    fi
}

remove_existing_container() {
  if docker ps -a --format '{{.Names}}' | grep -Eq "^${REGISTRY_CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container: $REGISTRY_CONTAINER_NAME"
    docker stop "$REGISTRY_CONTAINER_NAME"
    docker rm "$REGISTRY_CONTAINER_NAME"
  fi
}

uninstall_role() {
    bash "$UNINSTALL_ROLE_SCRIPT" "$SERVER_ROLE"
}


# Remove the registry data directory
cleanup_data_dir() {
    if [ -n "${REGISTRY_DATA_DIR:-}" ] && [ -d "$REGISTRY_DATA_DIR" ]; then
        echo "Removing registry data directory: $REGISTRY_DATA_DIR"
        rm -rf "$REGISTRY_DATA_DIR"
    fi
}


# Remove the cleanup cron job
remove_cleanup_cron() {
    # Remove any line containing /opt/registry/cleanup-registry.sh
    crontab -l 2>/dev/null | grep -v '/opt/registry/cleanup-registry.sh' | crontab -
}

main() {
    parse_args "$@"
    load_env
    run_pre_checks
    uninstall_role
    remove_existing_container
    cleanup_data_dir
    remove_cleanup_cron
}

main "$@"
