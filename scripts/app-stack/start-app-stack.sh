#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
ENV_FILE="$CURRENT_DIR/.env"

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
    if [ ! -f "$ENV_FILE" ]; then
        echo "Missing .env file with configuration."
        exit 1
    fi
}

load_env() {
    # shellcheck source=/dev/null
    source "$ENV_FILE"
}

ensure_data_dir() {
    if [ ! -d "$POSTGRES_DATA_DIR" ]; then
        mkdir -p "$POSTGRES_DATA_DIR"
    fi
}

start_app_stack() {
    echo "Starting app stack with Docker Compose..."
    docker compose -f "$CURRENT_DIR/docker-compose.yml" up -d
}

main() {
    parse_args "$@"
    run_pre_checks
    load_env
    ensure_data_dir
    start_app_stack

    echo "App stack started successfully."
}

main "$@"
