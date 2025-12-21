#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENV_EXAMPLE_FILE=".env.example"
CREATE_SERVICE_SCRIPT="${CURRENT_DIR}/create-service.sh"

SERVER_ROLE=""
SOURCE_PATH=""
INSTALL_PATH=""

# Includes
source "$CURRENT_DIR/lib/logging.sh"

parse_args() {
	log DEBUG "Parsing arguments..."
	if [ "$#" -lt 1 ]; then
		log ERROR "Usage: $0 <role>"
		exit 1
	fi
	SERVER_ROLE="$1"
	ROLE_START_SCRIPT="start-$SERVER_ROLE.sh"
	SOURCE_PATH="$CURRENT_DIR/../$SERVER_ROLE"
	INSTALL_PATH="/opt/$SERVER_ROLE"
}

run_pre_checks() {
	log DEBUG "Running pre-checks..."
	if [ ! -f "$SOURCE_PATH/$ROLE_START_SCRIPT" ]; then
		log ERROR "Launch script not found: $SOURCE_PATH/$ROLE_START_SCRIPT"
		exit 1
	fi
	if [ ! -f "$SOURCE_PATH/$ENV_EXAMPLE_FILE" ]; then
		log ERROR "SRC_.env.example file not found: $SOURCE_PATH/$ENV_EXAMPLE_FILE"
		exit 1
	fi
	if [ ! -f "$CREATE_SERVICE_SCRIPT" ]; then
		log ERROR "Service helper script not found: $CREATE_SERVICE_SCRIPT"
		exit 1
	fi
}

copy_files() {
	log INFO "Copying files to $INSTALL_PATH..."
	sudo mkdir -p "$INSTALL_PATH"
	sudo cp "$SOURCE_PATH/$ROLE_START_SCRIPT" "$INSTALL_PATH/"
	sudo cp "$SOURCE_PATH/$ENV_EXAMPLE_FILE" "$INSTALL_PATH/.env"
	sudo chmod 755 "$INSTALL_PATH/$ROLE_START_SCRIPT"
	sudo chmod 644 "$INSTALL_PATH/.env"
}

create_service() {
	sudo bash "$CREATE_SERVICE_SCRIPT" "$SERVER_ROLE" "$INSTALL_PATH/$ROLE_START_SCRIPT"
}

main() {
	parse_args "$@"
	run_pre_checks
	copy_files
	create_service

	log DEBUG "Role $SERVER_ROLE installed."
}

main "$@"
