#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOVE_SERVICE_SCRIPT="${CURRENT_DIR}/remove-service.sh"

SERVER_ROLE=""
INSTALL_DIR=""

print_usage() {
    echo "Usage: $0 <server-role>"
    echo "Example: $0 gha-runner"
}

parse_args() {
	if [ "$#" -lt 1 ]; then
		echo "Usage: $0 <server-role>"
		exit 1
	fi
    
	SERVER_ROLE="$1"
	INSTALL_DIR="/opt/$SERVER_ROLE"
}

run_pre_checks() {
    if [ ! -f "$REMOVE_SERVICE_SCRIPT" ]; then
		echo "Service helper script not found: $REMOVE_SERVICE_SCRIPT"
		exit 1
	fi
}

remove_service() {
    sudo bash "$REMOVE_SERVICE_SCRIPT" $SERVER_ROLE
}

remove_files() {
    if [ -d "$INSTALL_DIR" ]; then
        echo "Removing installation directory: $INSTALL_DIR"
        sudo rm -rf "$INSTALL_DIR"
    fi
}

print_success() {
    echo "Uninstallation complete. Service $SERVER_ROLE and related files have been removed."
}

main() {
    parse_args "$@"
    run_pre_checks
    remove_files
    remove_service
    print_success
}

main "$@"
