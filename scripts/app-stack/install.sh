#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

INSTALL_DOCKER_SCRIPT="$CURRENT_DIR/../shared/install-docker.sh"
INSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/install-role.sh"
SERVER_ROLE="app-stack"

# Includes
source "$CURRENT_DIR/../shared/logging.sh"

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

install_docker_if_needed() {
    log DEBUG "Installing Docker..."
    if ! command -v docker >/dev/null 2>&1; then
        bash "$INSTALL_DOCKER_SCRIPT"
        log INFO "Docker installation initiated. Please reboot the server and re-run this script."
        exit 0
    else
        log DEBUG "Docker already installed."
    fi
}

install_docker_compose_if_needed() {
    log DEBUG "Checking Docker Compose installation..."
    if ! docker compose version >/dev/null 2>&1; then
        log ERROR "Docker Compose plugin not found. Please install Docker Compose V2."
        exit 1
    else
        log DEBUG "Docker Compose already installed."
    fi
}

install_postgres_client_if_needed() {
    log DEBUG "Installing PostgreSQL client tools..."
    if ! command -v psql >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y postgresql-client
    else
        log DEBUG "PostgreSQL client already installed."
    fi
}

install_git_if_needed() {
    log DEBUG "Installing Git..."
    if ! command -v git >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y git
    else
        log DEBUG "Git already installed."
    fi
}

install_dependencies() {    
    log INFO "Installing dependencies..."
    install_docker_if_needed
    install_docker_compose_if_needed
    install_postgres_client_if_needed
    install_git_if_needed
}

copy_compose_file() {
    log INFO "Copying Docker Compose file..."
    local dest_dir="/opt/$SERVER_ROLE"
    local compose_src="$CURRENT_DIR/docker-compose.yml"
    if [ -f "$compose_src" ]; then
        sudo cp "$compose_src" "$dest_dir/"
    else
        log ERROR "Docker Compose file not found: $compose_src"
        exit 1
    fi
}

copy_cleanup_script() {
    log INFO "Copying backup cleanup script..."
    local dest_dir="/opt/$SERVER_ROLE"
    local script_src="$CURRENT_DIR/cleanup-backups.sh"
    if [ -f "$script_src" ]; then
        sudo cp "$script_src" "$dest_dir/"
        sudo chmod +x "$dest_dir/cleanup-backups.sh"
    else
        log ERROR "Cleanup script not found: $script_src"
        exit 1
    fi
}

schedule_cleanup_cron() {
    log INFO "Scheduling backup cleanup job..."
    # Schedule the cleanup script to run daily at 3 AM
    local cron_line="0 3 * * * /opt/$SERVER_ROLE/cleanup-backups.sh >/var/log/app-stack-backup-cleanup.log 2>&1"
    (sudo crontab -l 2>/dev/null | grep -v "/opt/$SERVER_ROLE/cleanup-backups.sh" || true; echo "$cron_line") | sudo crontab -
}

install_role() {
    log INFO "Installing app-stack role..."
    LOG_LEVEL="$LOG_LEVEL" bash "$INSTALL_ROLE_SCRIPT" "$SERVER_ROLE"

    # Additional role-specific installation tasks
    copy_compose_file
    copy_cleanup_script
    schedule_cleanup_cron
}

main() {
    parse_args "$@"
    run_pre_checks
    install_dependencies
    install_role
    log INFO "Installation complete. Edit /opt/$SERVER_ROLE/.env and compose files with your configuration."
    log INFO "Then start the service: sudo systemctl start $SERVER_ROLE.service"
}

main "$@"
