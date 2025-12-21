#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SERVICE_NAME=""
LAUNCH_SCRIPT=""
SERVICE_FILE=""

# Includes
source "$SCRIPT_DIR/logging.sh"

parse_args() {
    log DEBUG "Parsing arguments..."
    if [ "$#" -lt 2 ]; then
        log ERROR "Usage: $0 <service-name> <path-to-launch-script>"
        exit 1
    fi
    SERVICE_NAME="$1"
    LAUNCH_SCRIPT="$2"
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
}

run_pre_checks() {
    log DEBUG "Running pre-checks..."
    if [ ! -f "$LAUNCH_SCRIPT" ]; then
        log ERROR "Launch script $LAUNCH_SCRIPT not found. Please create it first."
        exit 1
    fi
}
    
create_service_file() {
    log INFO "Creating ${SERVICE_NAME}.service..."
    sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Service: $SERVICE_NAME (runs $LAUNCH_SCRIPT at startup)
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=$LAUNCH_SCRIPT
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
}

start_service() {
    log INFO "Starting service..."
    log DEBUG "Enabling and starting $SERVICE_NAME service..."
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME.service"
}

main() {
    parse_args "$@"
    run_pre_checks
    create_service_file
    start_service
    log DEBUG "Service creation complete."
}

main "$@"
