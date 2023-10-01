#!/usr/bin/env bash

set -e

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

function install_vault_cli() {
    echo "Downloading latest vault-cli image"
    docker pull quay.io/mynth/docker-vault-cli:latest 2>/dev/null
    docker create --name vault-cli \
        quay.io/mynth/docker-vault-cli > /dev/null
    docker cp \
        vault-cli:/usr/local/bin/vault-cli vault-cli > /dev/null
    docker rm vault-cli > /dev/null

    mkdir -p "$HOME/.local/bin"
    mv vault-cli "$HOME/.local/bin"

    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo "Your PATH does not include ~/.local/bin. Please add it to your PATH."
        exit 1
    fi

    vault-cli --version
    echo "Successfully installed vault-cli"
}

function wait_for_vault() {
  while true; do
    sleep 1
    if docker exec vault ls /vault/file/init.json > /dev/null 2>&1; then
      TOKEN=$(docker exec vault token)
      if [ -n "$TOKEN" ]; then
        echo "Vault is ready"
        break
      fi
    fi
  done
}

function run_vault() {
    echo "Downloading latest local-vault image"
    docker pull quay.io/mynth/local-vault:latest 2>/dev/null
    docker volume create vault > /dev/null
    docker stop vault > /dev/null 2>&1 || true
    docker rm vault > /dev/null 2>&1 || true
    docker run \
        --cap-add IPC_LOCK \
        --name vault \
        -v vault:/vault/file \
        -p 8200:8200 \
        -d \
        --restart unless-stopped quay.io/mynth/local-vault \
            > /dev/null
}

function check_token() {
    token="$(docker exec vault token)"
    if [ "$token" != "$VAULT_CLI_TOKEN" ]; then
        echo "VAULT_CLI_TOKEN needs to be defined."
        echo "Add the following to your shell profile:"
        echo "export VAULT_CLI_TOKEN=\"$token\""
    fi
}

install_vault_cli
echo
run_vault
wait_for_vault
echo
check_token
