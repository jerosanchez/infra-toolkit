#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

INSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/install-role.sh"
SERVER_ROLE="registry"

# Includes
source "$CURRENT_DIR/../shared/lib/logging.sh"
source "$CURRENT_DIR/../shared/lib/dependencies.sh"
source "$CURRENT_DIR/../shared/lib/scheduling.sh"

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

run_pre_checks() {
    if [ ! -f "$INSTALL_ROLE_SCRIPT" ]; then
        log ERROR "Shared install script not found or not executable: $INSTALL_ROLE_SCRIPT"
        exit 1
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


# Use shared scheduling function for cron jobs
schedule_cleanup_cron() {
    local daily_2am_cron="0 2 * * *"
    schedule "$SERVER_ROLE" "cleanup-registry.sh" "$daily_2am_cron"
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
