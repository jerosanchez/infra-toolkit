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

load_env() {
    if [ -f "$ENV_FILE" ]; then
        # shellcheck source=/dev/null
        source "$ENV_FILE"
    else
        echo "Missing .env file with configuration in $CURRENT_DIR. Exiting."
        exit 1
    fi
}

ensure_data_dir() {
    if [ ! -d "$REGISTRY_DATA_DIR" ]; then
        mkdir -p "$REGISTRY_DATA_DIR"
    fi
}

remove_existing_container() {
    if docker ps -a --format '{{.Names}}' | grep -Eq "^${REGISTRY_CONTAINER_NAME}$"; then
        echo "Stopping and removing existing container: $REGISTRY_CONTAINER_NAME"
        docker stop "$REGISTRY_CONTAINER_NAME"
        docker rm "$REGISTRY_CONTAINER_NAME"
    fi
}

launch_registry() {
    docker run -d --name "$REGISTRY_CONTAINER_NAME" \
        -p "$REGISTRY_PORT:5000" \
        -v "$REGISTRY_DATA_DIR:/var/lib/registry" \
        --restart=always \
        registry:2
}

main() {
    parse_args "$@"
    load_env
    ensure_data_dir
    remove_existing_container
    launch_registry
}

main "$@"
