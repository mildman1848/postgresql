# Make Targets

PostgreSQL follows the master Docker image template Makefile pattern with PostgreSQL-specific smoke/start behavior.

## Common local workflow

```bash
make env-setup
make validate
make build DOCKER='sudo docker'
make smoke DOCKER='sudo docker'
make security-scan DOCKER='sudo docker' TRIVY='sudo trivy'
make sbom DOCKER='sudo docker' SYFT='sudo syft'
make start DOCKER='sudo docker'
make status DOCKER='sudo docker'
make logs DOCKER='sudo docker'
```

## Core targets

| Target | Purpose |
|---|---|
| `make info` | Print image metadata and effective refs. |
| `make version` | Print `16.14-mldm1`. |
| `make env-setup` | Create local `.env` from `.env.example`. |
| `make env-validate` | Validate version/revision metadata. |
| `make lint` | Static repo checks, s6 checks, private-term scan, Hadolint. |
| `make validate` | `lint` + env validation + Actionlint. |
| `make test` | `validate` + PostgreSQL smoke test. |
| `make build` | Build local single-platform image with Buildx `--load`. |
| `make smoke` | Start temporary container and run healthcheck. |
| `make labels` | Inspect OCI labels of the built image. |
| `make security-scan` | Trivy config scan plus image scan if built. |
| `make sbom` | Generate SPDX JSON SBOM in `sbom/`. |
| `make start` | Start a persistent local dev PostgreSQL container. |
| `make stop` | Stop/remove the dev container. |
| `make logs` | Show dev container logs. |
| `make shell` | Open debug shell in image. |
| `make check-upstream` | Show LSIO base and Alpine package signal. |
| `make release-dry-run` | Print intended publish refs without pushing. |

## Important local Docker note

On systems where the current user cannot access `/var/run/docker.sock`, use matching privileges for Docker-backed tools:

```bash
make build DOCKER='sudo docker'
make security-scan DOCKER='sudo docker' TRIVY='sudo trivy'
make sbom DOCKER='sudo docker' SYFT='sudo syft'
```

Using `DOCKER='sudo docker'` alone is not enough for Trivy/Syft, because those tools also need Docker socket access.
