#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
ENV_FILE="$CURRENT_DIR/.env"

# Includes
source "$CURRENT_DIR/../shared/logging.sh"

print_usage() {
    echo "Usage: $0"
    echo "Cleans up old database backups."
}

parse_args() {
    if [ "$#" -gt 0 ]; then
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
    RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
}

run_pre_checks() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log WARN "Backup directory '$BACKUP_DIR' does not exist. Nothing to clean."
        exit 0
    fi
}

cleanup_old_backups() {
    log INFO "Cleaning up backups older than $RETENTION_DAYS days in $BACKUP_DIR..."
    find "$BACKUP_DIR" -type f -name '*.sql.gz' -mtime +"$RETENTION_DAYS" -print -delete
    log INFO "Cleanup complete."
}

main() {
    parse_args "$@"
    load_env
    run_pre_checks
    cleanup_old_backups
}

main "$@"
