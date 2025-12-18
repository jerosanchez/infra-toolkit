#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SERVICE_NAME=""
SERVICE_FILE=""

# Includes
source "$SCRIPT_DIR/logging.sh"

parse_args() {
    log DEBUG "Parsing arguments..."
    if [ "$#" -lt 1 ]; then
        log ERROR "Usage: $0 <service-name>"
        exit 1
    fi
    SERVICE_NAME="$1"
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
}

stop_and_disable_service() {
    log INFO "Stopping and disabling service..."
    if [ -f "$SERVICE_FILE" ]; then
        sudo systemctl stop "${SERVICE_NAME}.service" || true
        sudo systemctl disable "${SERVICE_NAME}.service" || true
    else
        log WARN "Service file $SERVICE_FILE does not exist."
    fi
}

remove_service() {
    log INFO "Removing ${SERVICE_NAME}.service..."
    stop_and_disable_service
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm -f "$SERVICE_FILE"
        sudo systemctl daemon-reload
    else
        log WARN "Service file $SERVICE_FILE does not exist."
    fi
}

main() {
    parse_args "$@"
    remove_service

    log DEBUG "Service removal complete."
}

main "$@"
