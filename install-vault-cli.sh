#!/usr/bin/env bash

set -e

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

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
echo "Successfully installed"
