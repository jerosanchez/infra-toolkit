#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
UNINSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/uninstall-role.sh"
SERVER_ROLE="gha-runner"

# Includes

source "$CURRENT_DIR/../shared/lib/logging.sh"

export LOG_LEVEL="INFO"

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
    if [ ! -x "$UNINSTALL_ROLE_SCRIPT" ]; then
        log ERROR "Shared uninstall script not found or not executable: $UNINSTALL_ROLE_SCRIPT"
        exit 1
    fi
    if [ -z "${CONFIG_DIR:-}" ]; then
        log ERROR "CONFIG_DIR is not set. Please check your .env file."
        exit 1
    fi
}

remove_existing_container() {
    if docker ps -a --format '{{.Names}}' | grep -Eq "^${RUNNER_NAME}$"; then
        log INFO "Stopping and removing existing container: $RUNNER_NAME"
        docker stop "$RUNNER_NAME"
        docker rm "$RUNNER_NAME"
    fi
}

cleanup_config_dir() {
    if [ -n "${CONFIG_DIR:-}" ] && [ -d "$CONFIG_DIR" ]; then
        log INFO "Removing config directory: $CONFIG_DIR"
        rm -rf "$CONFIG_DIR"
    fi
}

uninstall_role() {
    LOG_LEVEL="$LOG_LEVEL" bash "$UNINSTALL_ROLE_SCRIPT" "$SERVER_ROLE"

    # Additional role-specific uninstallation tasks
    remove_existing_container
    cleanup_config_dir
}

main() {
    parse_args "$@"
    load_env
    run_pre_checks
    uninstall_role

    echo "Uninstallation complete."
}

main "$@"
