set -euo pipefail

SCRIPT_SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_EXAMPLE=".env.example"
SERVICE_HELPER="${SCRIPT_SRC_DIR}/../shared/create-service.sh"

SERVER_ROLE=""
INSTALL_DIR=""
LAUNCH_SCRIPT=""

print_usage() {
	echo "Usage: $0 <role>"
}

parse_args() {
	if [ "$#" -lt 1 ]; then
		print_usage
		exit 1
	fi

	SERVER_ROLE="$1"
	INSTALL_DIR="/opt/$SERVER_ROLE"
	LAUNCH_SCRIPT="start-$SERVER_ROLE.sh"
}

run_pre_checks() {
	if [ ! -f "$SCRIPT_SRC_DIR/$LAUNCH_SCRIPT" ]; then
		echo "Launch script not found: $SCRIPT_SRC_DIR/$LAUNCH_SCRIPT"
		exit 1
	fi

	if [ ! -f "$SCRIPT_SRC_DIR/$ENV_EXAMPLE" ]; then
		echo ".env.example file not found: $SCRIPT_SRC_DIR/$ENV_EXAMPLE"
		exit 1
	fi

	if [ ! -f "$SERVICE_HELPER" ]; then
		echo "Service helper script not found: $SERVICE_HELPER"
		exit 1
	fi
}

copy_files() {
	echo "Copying files to $INSTALL_DIR..."
	sudo mkdir -p "$INSTALL_DIR"
	sudo cp "$SCRIPT_SRC_DIR/$LAUNCH_SCRIPT" "$INSTALL_DIR/"
	sudo cp "$SCRIPT_SRC_DIR/$ENV_EXAMPLE" "$INSTALL_DIR/.env"
	sudo chmod 755 "$INSTALL_DIR/$LAUNCH_SCRIPT"
	sudo chmod 644 "$INSTALL_DIR/.env"
}

create_service() {
	echo "Creating systemd service..."
	sudo "$SERVICE_HELPER" $SERVER_ROLE $INSTALL_DIR/$LAUNCH_SCRIPT
}

print_success() {
	echo "Installation complete."
	echo "Edit $INSTALL_DIR/.env and fill in your GitHub secrets."
	echo "Start the runner with: sudo systemctl start ${SERVER_ROLE}.service"
	echo "Check status with: sudo systemctl status ${SERVER_ROLE}.service"
}

main() {
	parse_args "$@"
	run_pre_checks
	copy_files
	create_service
	print_success
}

main "$@"
