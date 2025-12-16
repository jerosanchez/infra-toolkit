#!/bin/bash
set -euo pipefail

SERVICE_NAME=""
SERVICE_FILE=""

print_usage() {
    echo "Usage: $0 <service-name>"
}

parse_args() {
    if [ "$#" -lt 1 ]; then
        print_usage
        exit 1
    fi
    
    SERVICE_NAME="$1"
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
}

remove_service() {
    if systemctl list-units --full -all | grep -q "${SERVICE_NAME}.service"; then
        echo "Stopping and disabling systemd service: ${SERVICE_NAME}.service"
        sudo systemctl stop "${SERVICE_NAME}.service" || true
        sudo systemctl disable "${SERVICE_NAME}.service" || true
    fi
    if [ -f "$SERVICE_FILE" ]; then
        echo "Removing service file: $SERVICE_FILE"
        sudo rm -f "$SERVICE_FILE"
        sudo systemctl daemon-reload
    fi
}

print_success() {
    echo "Service $SERVICE_NAME stopped and removed."
}

main() {
    parse_args "$@"
    remove_service
    print_success
}

main "$@"
