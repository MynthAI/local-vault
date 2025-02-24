#!/usr/bin/env bash

set -e

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

function install_vault_cli() {
    VENV_DIR="$HOME/.virtualenvs/vault-cli"
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    pip install vault-cli

    if vault-cli --version; then
        sudo ln -sf $(which vault-cli) /usr/local/bin/vault-cli
        echo "vault-cli installed and linked"
    else
        echo "vault-cli installation failed"
        exit 1
    fi
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
