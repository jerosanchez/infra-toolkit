#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DOCKER_SCRIPT="$CURRENT_DIR/../shared/install-docker.sh"
INSTALL_ROLE_SCRIPT="$CURRENT_DIR/../shared/install-role.sh"
SERVER_ROLE="gha-runner"

# Includes

source "$CURRENT_DIR/../shared/lib/dependencies.sh"

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
    if [ ! -f "$INSTALL_DOCKER_SCRIPT" ]; then
        echo "Error: Docker install script not found or not executable: $INSTALL_DOCKER_SCRIPT"
        exit 1
    fi
    if [ ! -f "$INSTALL_ROLE_SCRIPT" ]; then
        echo "Error: Shared install script not found or not executable: $INSTALL_ROLE_SCRIPT"
        exit 1
    fi
}

install_dependencies() {
    install_docker_if_needed
    install_jq_if_needed
}

install_role() {
    bash "$INSTALL_ROLE_SCRIPT" "$SERVER_ROLE"
}

main() {
    parse_args "$@"
    install_dependencies
    run_pre_checks
    install_role
}

main "$@"
