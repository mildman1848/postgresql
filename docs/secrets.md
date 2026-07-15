# Secret Handling

## Policy

Secrets are generated with `make`, written to local files, and never printed to stdout.

Default generated secrets use:

- Python `secrets` module backed by OS CSPRNG;
- 96 characters by default;
- alphabet `A-Z a-z 0-9` for high compatibility with databases, YAML, shell, Docker secrets, and CI variables;
- file mode `0600`;
- no overwrite unless `FORCE=1` is set.

Entropy note: 96 characters from 62 symbols provides roughly 571 bits of entropy. That is far beyond what PostgreSQL/MariaDB passwords realistically need, while avoiding special-character escaping problems.

## Commands

Generate all pilot secrets:

```bash
make secrets
```

Generate PostgreSQL secret only:

```bash
make secret-postgresql
```

Generate MariaDB secrets only:

```bash
make secret-mariadb
```

Generate a custom secret:

```bash
make secret SECRET_NAME=secrets/my_service_password.txt
```

Use a different length if a target application has a documented limit:

```bash
make secret SECRET_NAME=secrets/api_token.txt SECRET_LENGTH=128
```

Overwrite intentionally:

```bash
make secret-postgresql FORCE=1
```

Delete local pilot secrets intentionally:

```bash
make clean-secrets FORCE=1
```

## Rules

- Do not commit generated `secrets/` directories.
- Prefer Docker secrets or bind-mounted secret files over `.env` passwords.
- Do not log secret values.
- If an upstream app documents a lower maximum password/token length, set `SECRET_LENGTH` explicitly and document why.
