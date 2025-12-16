#!/bin/bash

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
  if [ -f /home/jero/.env ]; then
    source /home/jero/.env
  else
    echo "Missing .env file with secrets. Exiting."
    exit 1
  fi
}

ensure_config_dir() {
  if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
  fi
}

get_registration_token() {
  REG_TOKEN=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_PAT" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/actions/runners/registration-token" \
    | jq -r .token)

  if [ "$REG_TOKEN" == "null" ] || [ -z "$REG_TOKEN" ]; then
    echo "Failed to get registration token. Check your PAT and repo details."
    exit 1
  fi
}

remove_existing_container() {
  if docker ps -a --format '{{.Names}}' | grep -Eq "^${RUNNER_NAME}$"; then
    echo "Stopping and removing existing container: $RUNNER_NAME"
    docker stop "$RUNNER_NAME"
    docker rm "$RUNNER_NAME"
  fi
}

launch_runner() {
  docker run -d --name $RUNNER_NAME \
    -v $CONFIG_DIR:/runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e RUNNER_NAME=$RUNNER_NAME \
    -e REPO_URL=https://github.com/$GITHUB_OWNER/$GITHUB_REPO \
    -e RUNNER_TOKEN=$REG_TOKEN \
    myoung34/github-runner:ubuntu-noble
}

main() {
  parse_args "$@"
  load_env
  ensure_config_dir
  get_registration_token
  remove_existing_container
  launch_runner
}

main "$@"
