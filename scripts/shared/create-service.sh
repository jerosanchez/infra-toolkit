#!/bin/bash
set -euo pipefail

SERVICE_NAME=""
LAUNCH_SCRIPT=""
SERVICE_FILE=""

print_usage() {
    echo "Usage: $0 <service-name> <path-to-launch-script>"
}

parse_args() {
    if [ "$#" -lt 2 ]; then
        print_usage
        exit 1
    fi

    SERVICE_NAME="$1"
    LAUNCH_SCRIPT="$2"
    SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
}

run_pre_checks() {
    if [ ! -f "$LAUNCH_SCRIPT" ]; then
        print_error "Launch script $LAUNCH_SCRIPT not found. Please create it first."
    fi
}
    
create_service_file() {
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

reload_and_enable_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME.service"
}

print_success() {
    echo "Service $SERVICE_NAME installed and enabled."
}

main() {
    parse_args "$@"
    run_pre_checks
    create_service_file
    reload_and_enable_service
    print_success
}

main "$@"
