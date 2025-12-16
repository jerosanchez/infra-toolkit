#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_ROLE_SCRIPT="$SCRIPTS_DIR/../shared/install-role.sh"
INSTALL_DOCKER_SCRIPT="$SCRIPTS_DIR/../shared/install-docker.sh"
SERVER_ROLE="gha-runner"

NAME=""

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
    if [ ! -x "$SHARED_INSTALL_SCRIPT" ]; then
        echo "Error: Shared install script not found or not executable: $SHARED_INSTALL_SCRIPT"
        exit 1
    fi
    if [ ! -x "$INSTALL_DOCKER_SCRIPT" ]; then
        echo "Error: Docker install script not found or not executable: $INSTALL_DOCKER_SCRIPT"
        exit 1
    fi
}

install_docker_if_needed() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker not found. Installing Docker..."
        "$INSTALL_DOCKER_SCRIPT"
        echo "Docker installation initiated. Please reboot the server and re-run this script."
        exit 0
    fi
}

install_role() {
    "$INSTALL_ROLE_SCRIPT" "$SERVER_ROLE"
}

main() {
    parse_args "$@"
    run_pre_checks
    install_docker_if_needed
    install_role
}

main "$@"
