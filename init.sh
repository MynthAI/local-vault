#!/bin/bash

wait-for-it 127.0.0.1:8200

# Initialize Vault if not initialized
if [ ! -f /vault/file/init.json ]; then
    vault operator init -n 1 -t 1 -format=json > \
        /vault/file/init.json
fi

# Grab the Vault token
VAULT_CLI_TOKEN="$(jq -r '.root_token' /vault/file/init.json)"

# Unseal the Vault and login
VAULT_UNSEAL_KEYS="$(jq -r '.unseal_keys_b64[0]' /vault/file/init.json)"
vault operator unseal "$VAULT_UNSEAL_KEYS"
vault login "$VAULT_CLI_TOKEN"
