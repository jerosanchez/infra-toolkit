#!/bin/bash

install_docker_if_needed() {
    log DEBUG "Installing Docker..."
    local CURRENT_DIR
    CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if ! command -v docker >/dev/null 2>&1; then
        sudo bash "$CURRENT_DIR/install-docker.sh"
        exit 0
    else
        log DEBUG "Docker already installed."
    fi
}

install_docker_compose_if_needed() {
    log DEBUG "Checking Docker Compose installation..."
    if ! docker compose version >/dev/null 2>&1; then
        log ERROR "Docker Compose plugin not found. Please install Docker Compose V2."
        exit 1
    else
        log DEBUG "Docker Compose already installed."
    fi
}

install_postgres_client_if_needed() {
    log DEBUG "Installing PostgreSQL client tools..."
    if ! command -v psql >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y postgresql-client
    else
        log DEBUG "PostgreSQL client already installed."
    fi
}

install_crontab_if_needed() {
    log DEBUG "Installing 'crontab' (cron package)..."
    if ! command -v crontab >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y cron
    else
        log DEBUG "'crontab' already installed."
    fi
}

install_jq_if_needed() {
    log DEBUG "Installing 'jq' (JSON tool)..."
    if ! command -v jq >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y jq
    else
        log DEBUG "'jq' already installed."
    fi
}
