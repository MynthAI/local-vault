# Local Vault

The `quay.io/mynth/local-vault` Docker container simplifies working with
a local instance of Vault. The container runs a single Vault instance
with persistent storage. Upon starting, Vault is automatically
initialized and unsealed.

## Installation

To activate Vault on your computer, execute the command below:

    curl -sSL https://raw.githubusercontent.com/MynthAI/local-vault/main/install-vault.sh | bash

If you’re running this script for the first time, it will generate a
Vault token. You should save this token to your shell environment, such
as `~/.bashrc` or `~/.zshrc`.

### Enabling Secrets

After the container is running, you can access the `vault` command to
interact with Vault. For example, to enable the “my-app” secrets path,
use:

``` bash
docker exec vault vault secrets enable -path=my-app -version=1 kv
```

### Reading and Writing Secrets with vault-cli

[vault-cli](https://vault-cli.readthedocs.io/en/latest/) is a tool that
provides easy ways to handle secrets from Hashicorp Vault. It gets
installed automatically when you follow the above instructions.

You can save secrets into your local Vault instance using `vault-cli
set`. For example, save a password using:

``` bash
vault-cli set -p my-app/db password
```

Enter a password and press enter. To read the saved secret, use
`vault-cli get`. For example, read back your saved password using:

``` bash
vault-cli get my-app/db password
```
