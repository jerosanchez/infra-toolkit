#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
ENV_FILE="$CURRENT_DIR/.env"

BACKUP_DIR=""

# Includes
source "$CURRENT_DIR/../shared/logging.sh"

print_usage() {
    echo "Usage: $0"
    echo "Backs up the database to $BACKUP_DIR with a timestamped filename."
}

parse_args() {
    if [ "$#" -ne 0 ]; then
        print_usage
        exit 1
    fi
}

load_env() {
    if [ -f "$ENV_FILE" ]; then
        # shellcheck source=/dev/null
        source "$ENV_FILE"
    else
        log ERROR "Missing .env file with configuration in $CURRENT_DIR. Exiting."
        exit 1
    fi
    BACKUP_DIR="${BACKUP_DIR:-/opt/app-stack/backups}"
}

run_pre_checks() {
    local container_name="${COMPOSE_PROJECT_NAME:-app-stack}-postgres"
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log ERROR "Postgres container '$container_name' is not running."
        exit 1
    fi
    if [ ! -d "$BACKUP_DIR" ]; then
        log INFO "Backup directory '$BACKUP_DIR' does not exist. Creating it."
        mkdir -p "$BACKUP_DIR"
    fi
}

backup_database() {
    local container_name="${COMPOSE_PROJECT_NAME:-app-stack}-postgres"
    local timestamp
    timestamp="$(date +%Y%m%d-%H%M%S)"
    local backup_file
    backup_file="$BACKUP_DIR/${POSTGRES_DB:-appdb}-$timestamp.sql.gz"

    log INFO "Backing up database '$POSTGRES_DB' to '$backup_file'..."
    if docker exec "$container_name" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$backup_file"; then
        log INFO "Backup completed successfully: $backup_file"
    else
        log ERROR "Backup failed."
        exit 1
    fi
}

main() {
    parse_args "$@"
    load_env
    run_pre_checks
    backup_database
}

main "$@"
