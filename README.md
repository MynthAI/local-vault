# Local Vault

The `quay.io/mynth/local-vault` Docker container simplifies working with
a local instance of Vault. The container runs a single Vault instance
with persistent storage. Upon starting, Vault is automatically
initialized and unsealed.

## Usage

To enable Vault to store persistent data, create a volume by running the
following command:

``` bash
docker volume create vault
```

To start Vault, run the following command:

``` bash
docker run --rm -d \
  --name vault \
  --cap-add=IPC_LOCK \
  -v vault:/vault/file \
  -p 8200:8200 quay.io/mynth/local-vault
```

To interact with Vault, you will need the root token. You can obtain the
root token from the `token` command within the running container:

``` bash
docker exec vault token
```

To simplify things, you can extract the root token and store it in the
`VAULT_CLI_TOKEN` environment variable. Here’s an example:

``` bash
echo "export VAULT_CLI_TOKEN=\"$(docker exec vault token)\"" >> ~/.bashrc
```

### Enabling Secrets

After the container is running, you can access the `vault` command to
interact with Vault. For example, to enable the “my-app” secrets path,
use:

``` bash
docker exec vault vault secrets enable -path=my-app -version=1 kv
```

### Reading and Writing Secrets with vault-cli

[vault-cli](https://vault-cli.readthedocs.io/en/latest/) is a tool that
offers simple interactions to manipulate secrets from Hashicorp Vault.
You can install `vault-cli` by running the following:

    curl -sSL https://raw.githubusercontent.com/MynthAI/local-vault/main/install-vault-cli.sh | bash

Now you can save secrets into your local Vault instance using `vault-cli
set`. For example, save a password using:

``` bash
vault-cli set -p my-app/db password
```

Enter a password and press enter. To read the saved secret, use
`vault-cli get`. For example, read back your saved password using:

``` bash
vault-cli get my-app/db password
```
