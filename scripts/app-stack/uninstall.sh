#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

UNINSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/uninstall-role.sh"
SERVER_ROLE="app-stack"

# Includes
source "$CURRENT_DIR/../shared/lib/logging.sh"
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

load_env() {
    log DEBUG "Loading environment variables..."
    if [ -f /opt/$SERVER_ROLE/.env ]; then
        # shellcheck source=/dev/null
        source "/opt/$SERVER_ROLE/.env"
    fi
}

run_pre_checks() {
    log DEBUG "Running pre-checks..."
    if [ ! -f "$UNINSTALL_ROLE_SCRIPT" ]; then
        log ERROR "Script not found or not executable: $UNINSTALL_ROLE_SCRIPT"
        exit 1
    fi
    if [ ! -f "/opt/$SERVER_ROLE/.env" ]; then
        log ERROR "No .env file found."
        exit 1
    fi
    if [ ! -f "/opt/$SERVER_ROLE/docker-compose.yml" ]; then
        log ERROR "No docker-compose.yml file found."
        exit 1
    fi
}

stop_compose_stack() {
    log INFO "Stopping Docker Compose stack..."
    cd /opt/$SERVER_ROLE
    docker compose down || log WARN "Failed to stop compose stack."
}

remove_containers() {
    log INFO "Removing app stack containers..."
    local project_name="${COMPOSE_PROJECT_NAME:-app-stack}"
    if docker ps -a --format '{{.Names}}' | grep -q "^${project_name}-"; then
        docker ps -a --format '{{.Names}}' | grep "^${project_name}-" | xargs -r docker rm -f
    else
        log WARN "No app stack containers found."
    fi
}

uninstall_role() {
    LOG_LEVEL="$LOG_LEVEL" bash "$UNINSTALL_ROLE_SCRIPT" "$SERVER_ROLE"

    # Additional role-specific uninstallation tasks
    unschedule "$SERVER_ROLE" "backup-database.sh"
    unschedule "$SERVER_ROLE" "cleanup-backups.sh"  
}

main() {
    parse_args "$@"
    load_env
    run_pre_checks
    stop_compose_stack
    remove_containers
    uninstall_role

    echo  "Uninstallation complete."
}

main "$@"
