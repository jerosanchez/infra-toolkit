#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REMOVE_SERVICE_SCRIPT="${CURRENT_DIR}/remove-service.sh"

SERVER_ROLE=""
INSTALL_DIR=""

# Includes
source "$CURRENT_DIR/logging.sh"

parse_args() {
    log DEBUG "Parsing arguments..."
    if [ "$#" -lt 1 ]; then
        log ERROR "Usage: $0 <server-role>"
        exit 1
    fi
    SERVER_ROLE="$1"
    INSTALL_DIR="/opt/$SERVER_ROLE"
}

run_pre_checks() {
    log DEBUG "Running pre-checks..."
    if [ ! -f "$REMOVE_SERVICE_SCRIPT" ]; then
        log ERROR "Service helper script not found: $REMOVE_SERVICE_SCRIPT"
        exit 1
    fi
}

remove_service() {
    sudo LOG_LEVEL="$LOG_LEVEL" bash "$REMOVE_SERVICE_SCRIPT" "$SERVER_ROLE"
}

remove_files() {
    log INFO "Removing installation directory..."
    if [ -d "$INSTALL_DIR" ]; then
        sudo rm -rf "$INSTALL_DIR"
    else
        log WARN "Directory $INSTALL_DIR not found."
    fi
}

main() {
    parse_args "$@"
    run_pre_checks
    remove_service
    remove_files

    log DEBUG "Role $SERVER_ROLE uninstalled."
}

main "$@"
