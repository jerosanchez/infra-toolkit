#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

INSTALL_DOCKER_SCRIPT="$CURRENT_DIR/../shared/install-docker.sh"
INSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/install-role.sh"
SERVER_ROLE="registry"

# Includes
source "$CURRENT_DIR/../shared/logging.sh"
LOG_LEVEL="INFO"

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

run_pre_checks() {
    log DEBUG "Running pre-checks..."
    if [ ! -f "$INSTALL_DOCKER_SCRIPT" ]; then
        log ERROR "Docker install script not found or not executable: $INSTALL_DOCKER_SCRIPT"
        exit 1
    fi
    if [ ! -f "$INSTALL_ROLE_SCRIPT" ]; then
        log ERROR "Shared install script not found or not executable: $INSTALL_ROLE_SCRIPT"
        exit 1
    fi
}

install_jq_if_needed() {
    log DEBUG "Installing 'jq' (JSON tool)..."
    if ! command -v jq >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y jq
    else
        log DEBUG "'jq' already installed."
    fi
}

install_crontab_if_needed() {
    log DEBUG "Installing 'crontab' (cron package)..."
    if ! command -v crontab >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y cron
    else
        log DEBUG "'crontab' already installed."
    fi
}

install_docker_if_needed() {
    log DEBUG "Installing Docker..."
    if ! command -v docker >/dev/null 2>&1; then
        sudo LOG_LEVEL="$LOG_LEVEL" bash "$INSTALL_DOCKER_SCRIPT"
        log INFO "Docker installation initiated. Please reboot the server and re-run this script."
        exit 0
    else
        log DEBUG "Docker already installed."
    fi
}

install_dependencies() {    
    log INFO "Installing dependencies..."
    install_jq_if_needed
    install_docker_if_needed
    install_crontab_if_needed
}

copy_cleanup_script() {
    log INFO "Copying cleanup script..."
    local dest_dir="/opt/registry"
    local script_src="$CURRENT_DIR/cleanup-registry.sh"
    if [ -f "$script_src" ]; then
        sudo cp "$script_src" "$dest_dir/"
        sudo chmod +x "$dest_dir/cleanup-registry.sh"
    else
        log ERROR "Cleanup script not found: $script_src"
    fi
}

schedule_cleanup_cron() {
    log INFO "Scheduling cleanup job..."
    # Schedule the cleanup script to run daily at 2 AM
    local cron_line="0 2 * * * /opt/registry/cleanup-registry.sh 7 >/var/log/registry-cleanup.log 2>&1"
    (sudo crontab -l 2>/dev/null | grep -v '/opt/registry/cleanup-registry.sh' || true; echo "$cron_line") | sudo crontab -
}

install_role() {
    LOG_LEVEL="$LOG_LEVEL" bash "$INSTALL_ROLE_SCRIPT" "$SERVER_ROLE"

    # Additional role-specific installation tasks
    copy_cleanup_script
    schedule_cleanup_cron
}

start_registry() {
    log INFO "Starting registry..."
    sudo /opt/registry/start-registry.sh
}

print_success_message() {
    echo "Installation complete."
    echo "Edit /opt/$SERVER_ROLE/.env with your configuration."
    echo "Then start the service: sudo systemctl start $SERVER_ROLE.service"
}

main() {
    parse_args "$@"
    install_dependencies
    run_pre_checks
    install_role
    start_registry
    print_success_message
}

main "$@"
