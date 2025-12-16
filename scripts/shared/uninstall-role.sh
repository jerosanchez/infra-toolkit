#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SERVER_ROLE=""
INSTALL_DIR=""
LAUNCH_SCRIPT=""

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
	LAUNCH_SCRIPT="start-$SERVER_ROLE.sh"
}

run_pre_checks() {
    if [ ! -x "$remove_service_script" ]; then
        echo "Error: remove-service.sh not found or not executable: $remove_service_script"
        exit 1
    fi
}

call_remove_service() {
    local remove_service_script="$SCRIPTS_DIR/remove-service.sh"
    
    "$remove_service_script" "$SERVER_ROLE"
}

remove_installation_files() {
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
    call_remove_service
    remove_installation_files
    print_success
}

main "$@"
