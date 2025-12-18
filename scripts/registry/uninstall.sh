#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

UNINSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/uninstall-role.sh"
SERVER_ROLE="registry"

# Includes
source "$CURRENT_DIR/../shared/logging.sh"
export LOG_LEVEL="DEBUG"

print_usage() {
    echo "Usage: $0"
}

parse_args() {
    log DEBUG "Parsing arguments..."
    if [ "$#" -ne 0 ]; then
        print_usage
        exit 1
    fi
}

load_env() {
    log DEBUG "Loading environment variables..."
    if [ -f /opt/$SERVER_ROLE/.env ]; then
        # shellcheck source=/dev/null
        source "/opt/$SERVER_ROLE/.env"
    fi
}

run_pre_checks() {
    log DEBUG "Running pre-checks..."
    if [ ! -f "$UNINSTALL_ROLE_SCRIPT" ]; then
        log ERROR "Script not found or not executable: $UNINSTALL_ROLE_SCRIPT"
        exit 1
    fi
    if [ ! -f "/opt/$SERVER_ROLE/.env" ]; then
        log WARN "No .env file found."
    fi
}

remove_existing_container() {
    log INFO "Removing existing container..."
    if [ -z "${REGISTRY_CONTAINER_NAME:-}" ]; then
        log WARN "REGISTRY_CONTAINER_NAME is not set. Skipping container removal."
        return 0
    fi
    if docker ps -a --format '{{.Names}}' | grep -Eq "^${REGISTRY_CONTAINER_NAME}$"; then
        docker stop "$REGISTRY_CONTAINER_NAME"
        docker rm "$REGISTRY_CONTAINER_NAME"
    else
        log WARN "No existing container found."
    fi
}

uninstall_role() {
    LOG_LEVEL="$LOG_LEVEL" bash "$UNINSTALL_ROLE_SCRIPT" "$SERVER_ROLE"
}

cleanup_data_dir() {
    log INFO "Removing registry data directory..."
    if [ -n "${REGISTRY_DATA_DIR:-}" ] && [ -d "$REGISTRY_DATA_DIR" ]; then
        rm -rf "$REGISTRY_DATA_DIR"
    else
        log WARN "Data directory not found."
    fi
}

remove_cleanup_cron() {
    log INFO "Removing cleanup job..."
    # Remove any line containing /opt/registry/cleanup-registry.sh
    (sudo crontab -l 2>/dev/null | grep -v '/opt/registry/cleanup-registry.sh' || true; echo "") | sudo crontab -
}

main() {
    parse_args "$@"
    load_env
    run_pre_checks
    uninstall_role
    remove_existing_container
    cleanup_data_dir
    remove_cleanup_cron

    log INFO "Registry uninstallation complete."
}

main "$@"
