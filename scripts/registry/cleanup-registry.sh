#!/bin/bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
ENV_FILE="$CURRENT_DIR/.env"

print_usage() {
    echo "Usage: $0 <retention-days>"
    echo "Default retention is 7 days if not specified."
}

parse_args() {
    if [ "$#" -gt 1 ]; then
        print_usage
        exit 1
    fi
    RETENTION_DAYS="${1:-7}"
}

run_pre_checks() {
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${REGISTRY_PORT}/v2/_catalog" || true)
    if [ "$status" != "200" ]; then
        echo "Error: Docker registry is not accessible at http://localhost:${REGISTRY_PORT}. (HTTP status: $status)"
        echo "Ensure the registry service is running and accessible."
        exit 1
    fi
}

load_env() {
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    else
        echo "Missing .env file with configuration in $CURRENT_DIR. Exiting."
        exit 1
    fi
}

list_repositories() {
    curl -s "http://localhost:${REGISTRY_PORT}/v2/_catalog" | jq -r '.repositories[]'
}

list_tags() {
    local repo="$1"
    curl -s "http://localhost:${REGISTRY_PORT}/v2/${repo}/tags/list" | jq -r '.tags[]'
}

get_manifest_created() {
    local repo="$1" tag="$2"
    curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        "http://localhost:${REGISTRY_PORT}/v2/${repo}/manifests/${tag}" \
        | jq -r '.history[0].v1Compatibility' 2>/dev/null | jq -r '.created' 2>/dev/null
}

get_digest() {
    local repo="$1" tag="$2"
    curl -sI -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        "http://localhost:${REGISTRY_PORT}/v2/${repo}/manifests/${tag}" \
        | grep Docker-Content-Digest | awk '{print $2}' | tr -d $'\r'
}

delete_manifest() {
    local repo="$1" digest="$2"
    curl -s -X DELETE "http://localhost:${REGISTRY_PORT}/v2/${repo}/manifests/${digest}"
}

run_garbage_collect() {
    docker exec "$REGISTRY_CONTAINER_NAME" registry garbage-collect /etc/docker/registry/config.yml
}

delete_old_tag_if_expired() {
    local repo="$1" tag="$2" created="$3"
    if [ -n "$created" ]; then
        local created_ts now_ts age_days digest
        created_ts=$(date -d "$created" +%s)
        now_ts=$(date +%s)
        age_days=$(( (now_ts - created_ts) / 86400 ))
        if [ "$age_days" -gt "$RETENTION_DAYS" ]; then
            digest=$(get_digest "$repo" "$tag")
            if [ -n "$digest" ]; then
                delete_manifest "$repo" "$digest"
                echo "Deleted $repo:$tag (age: ${age_days}d)"
            fi
        fi
    fi
}

cleanup_old_images() {
    local created
    for repo in $(list_repositories); do
        for tag in $(list_tags "$repo"); do
            created=$(get_manifest_created "$repo" "$tag")
            delete_old_tag_if_expired "$repo" "$tag" "$created"
        done
    done
}

main() {
    parse_args "$@"
    run_pre_checks
    load_env
    cleanup_old_images
    run_garbage_collect
}

main "$@"
