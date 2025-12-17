#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
INSTALL_DOCKER_SCRIPT="$CURRENT_DIR/../shared/install-docker.sh"
INSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/install-role.sh"
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

run_pre_checks() {
    if [ ! -f "$INSTALL_DOCKER_SCRIPT" ]; then
        echo "Error: Docker install script not found or not executable: $INSTALL_DOCKER_SCRIPT"
        exit 1
    fi
    if [ ! -f "$INSTALL_ROLE_SCRIPT" ]; then
        echo "Error: Shared install script not found or not executable: $INSTALL_ROLE_SCRIPT"
        exit 1
    fi
}

install_jq_if_needed() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "Installing 'jq' (JSON tool)..."
        sudo apt-get update
        sudo apt-get install -y jq
    fi
}

install_docker_if_needed() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker not found. Installing Docker..."
        bash "$INSTALL_DOCKER_SCRIPT"
        echo "Docker installation initiated. Please reboot the server and re-run this script."
        exit 0
    fi
}

install_dependencies() {
    install_jq_if_needed
    install_docker_if_needed
}

copy_cleanup_script() {
    local dest_dir="/opt/registry"
    local script_src="$CURRENT_DIR/cleanup-registry.sh"
    if [ -f "$script_src" ]; then
        sudo cp "$script_src" "$dest_dir/"
        sudo chmod +x "$dest_dir/cleanup-registry.sh"
    fi
}

schedule_cleanup_cron() {
    # Schedule the cleanup script to run daily at 2 AM with a retention of 7 days
    local cron_line="0 2 * * * /opt/registry/cleanup-registry.sh 7 >/var/log/registry-cleanup.log 2>&1"
    # Remove any existing line for this script before adding the new one
    (crontab -l 2>/dev/null | grep -v '/opt/registry/cleanup-registry.sh'; echo "$cron_line") | crontab -
}

install_role() {
    bash "$INSTALL_ROLE_SCRIPT" "$SERVER_ROLE"
    copy_cleanup_script
    schedule_cleanup_cron
}

main() {
    parse_args "$@"
    install_dependencies
    run_pre_checks
    install_role
}

main "$@"
