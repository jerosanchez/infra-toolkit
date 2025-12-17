#!/bin/bash
set -euo pipefail

print_usage() {
    echo "Usage: $0"
}

parse_args() {
    if [ "$#" -ne 0 ]; then
        print_usage
        exit 1
    fi
}

update_packages() {
    echo "Updating package lists..."
    sudo apt update
}

install_prerequisites() {
    echo "Installing prerequisites..."
    sudo apt -y install ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
}

add_docker_repo() {
    echo "Adding Docker's official repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
}

install_docker() {
    echo "Installing Docker Engine and related packages..."
    sudo apt -y install docker-ce docker-ce-cli containerd.io
}

add_user_to_docker_group() {
    echo "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
}

reboot_message() {
    echo "Docker installation complete."
    echo "You must reboot the server to complete the installation."
    echo "Run: sudo reboot"
    echo "After reboot, verify with: docker --version"
}

main() {
    update_packages
    install_prerequisites
    add_docker_repo
    install_docker
    add_user_to_docker_group
    reboot_message
}

main "$@"
