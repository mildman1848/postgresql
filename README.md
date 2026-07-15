# PostgreSQL LSIO

LinuxServer.io-style s6-overlay container image for postgresql.

This is a standalone image repository derived from `mildman1848-docker-image-template`.

## Quick start

```bash
make help
make secrets
make lint
IMAGE_TAG=dev PLATFORMS=linux/amd64 make build
make smoke
```

## Ports

- `5432`

## Registries

Initial target after local validation:

- GHCR
- Docker Hub

GitLab and Codeberg registry targets will be added after PostgreSQL and MariaDB both build and pass smoke tests.
