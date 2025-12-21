#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

INSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/install-role.sh"
SERVER_ROLE="app-stack"

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

install_dependencies() {    
    log INFO "Installing dependencies..."
    install_docker_if_needed
    install_docker_compose_if_needed
    install_postgres_client_if_needed
    install_crontab_if_needed
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


# Use shared scheduling function for cron jobs
schedule_backup_cron() {
    local daily_2am_cron="0 2 * * *"
    schedule "$SERVER_ROLE" "backup-database.sh" "$daily_2am_cron"
}

schedule_cleanup_cron() {
    local daily_3pm_cron="0 15 * * *"
    schedule "$SERVER_ROLE" "cleanup-backups.sh" "$daily_3pm_cron"
}

install_role() {
    copy_file "Copying Docker Compose file..." "$CURRENT_DIR/docker-compose.yml"

    sudo LOG_LEVEL="$LOG_LEVEL" bash "$INSTALL_ROLE_SCRIPT" "$SERVER_ROLE"

    # Additional role-specific installation tasks
    copy_script "Copying database backup script..." "$CURRENT_DIR/backup-database.sh"
    copy_script "Copying backup cleanup script..." "$CURRENT_DIR/cleanup-backups.sh"

    schedule_backup_cron
    schedule_cleanup_cron
}

print_success_message() {
    echo "Installation complete."
    
    echo "Edit /opt/$SERVER_ROLE/.env and compose files with your configuration."
    echo "Then start the service: sudo systemctl start $SERVER_ROLE.service"
}

main() {
    parse_args "$@"
    run_pre_checks
    install_dependencies
    install_role
    print_success_message
}

main "$@"
