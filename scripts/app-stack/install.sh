#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

INSTALL_DOCKER_SCRIPT="$CURRENT_DIR/../shared/install-docker.sh"
INSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/install-role.sh"
SERVER_ROLE="app-stack"

# Includes
source "$CURRENT_DIR/../shared/logging.sh"
export LOG_LEVEL="DEBUG"

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

copy_file() {
    local message="$1"
    local file_src="$2"
    local dest_dir="/opt/$SERVER_ROLE"
    local file_name
    file_name="$(basename "$file_src")"

    log INFO "$message"
    if [ ! -d "$dest_dir" ]; then
        sudo mkdir -p "$dest_dir"
    fi
    if [ -f "$file_src" ]; then
        sudo cp "$file_src" "$dest_dir/"
        sudo chmod +x "$dest_dir/$file_name"
    else
        log ERROR "File not found: $file_src"
        exit 1
    fi
}

copy_script() {
    local message="$1"
    local file_src="$2"
    local dest_dir="/opt/$SERVER_ROLE"
    local file_name
    file_name="$(basename "$file_src")"

    copy_file "$message" "$file_src"
    
    sudo chmod +x "$dest_dir/$file_name"
}

schedule_backup_cron() {
    log INFO "Scheduling database backup job..."
    # Schedules the database backup script to run daily at 2 AM
    local cron_line="0 2 * * * /opt/$SERVER_ROLE/backup-database.sh >/var/log/app-stack-backup.log 2>&1"
    (sudo crontab -l 2>/dev/null | grep -v "/opt/$SERVER_ROLE/backup-database.sh" || true; echo "$cron_line") | sudo crontab -
}

schedule_cleanup_cron() {
    log INFO "Scheduling backup cleanup job..."
    # Schedule the cleanup script to run daily at 3 PM
    local cron_line="0 15 * * * /opt/$SERVER_ROLE/cleanup-backups.sh >/var/log/app-stack-backup-cleanup.log 2>&1"
    (sudo crontab -l 2>/dev/null | grep -v "/opt/$SERVER_ROLE/cleanup-backups.sh" || true; echo "$cron_line") | sudo crontab -
}

install_role() {
    copy_file "Copying Docker Compose file..." "$CURRENT_DIR/docker-compose.yml"

    sudo LOG_LEVEL="$LOG_LEVEL" bash "$INSTALL_ROLE_SCRIPT" "$SERVER_ROLE"

    # Additional role-specific installation tasks
    copy_script "Copying database backup script..." "$CURRENT_DIR/backup-database.sh"
    schedule_backup_cron
    copy_script "Copying backup cleanup script..." "$CURRENT_DIR/cleanup-backups.sh"
    schedule_cleanup_cron
}

print_success_message() {
    log INFO "Installation complete."
    log INFO "Edit /opt/$SERVER_ROLE/.env and compose files with your configuration."
    log INFO "Then start the service: sudo systemctl start $SERVER_ROLE.service"
}

main() {
    parse_args "$@"
    run_pre_checks
    install_dependencies
    install_role
    print_success_message
}

main "$@"
