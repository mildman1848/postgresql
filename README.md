# PostgreSQL LSIO Image

LinuxServer.io-style s6-overlay container image for PostgreSQL.

This is a standalone image repository derived from [`mildman1848-docker-image-template`](https://github.com/mildman1848/mildman1848-docker-image-template).

## Status

- Local amd64 build: passing.
- Local smoke test: passing.
- Multiarch CI: prepared.
- Registry publishing: GHCR and Docker Hub first; GitLab and Codeberg-compatible registries are prepared but should only be enabled after CI builds are green.

## Quick start

```bash
make help
make secrets
make lint
IMAGE_TAG=dev PLATFORMS=linux/amd64 make build
make smoke
```

## Versioning

This image follows the template versioning format:

```text
<upstream-version>-mld<N>
```

Current image version:

```text
16.14-mld1
```

- Upstream application/package version: `16.14`
- Image revision: `mld1`

## Runtime conventions

- Persistent data: `/config`
- Runtime user: `abc`, controlled by `PUID`/`PGID`
- Timezone: `TZ`
- Secrets: `FILE__*` mounted files

## Documentation

- `UPSTREAM.md` — upstream source, packaging approach, and divergence from official images.
- `CHANGELOG.md` — project changes.
- `docs/secrets.md` — secret generation and handling.
- `docs/licensing.md` — license notes.

## Registries

Configured targets after validation:

- GHCR: `ghcr.io/mildman1848/postgresql-lsio`
- Docker Hub: `docker.io/<DOCKERHUB_USERNAME>/postgresql-lsio`
- GitLab: `registry.gitlab.com/mildman1848/postgresql-lsio`
- Codeberg-compatible registry: `codeberg.org/mildman1848/postgresql-lsio`

Publishing is manual through GitHub Actions `workflow_dispatch` with `push=true`.
