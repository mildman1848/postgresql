# PostgreSQL

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

## Description

PostgreSQL packaged in a LinuxServer.io-style s6 container.

This repository builds the `postgresql` container image. It uses a LinuxServer.io-style runtime, s6-overlay supervision, `/config` persistence, secure local secret generation, and CI-based multi-platform builds.

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

- GHCR: `ghcr.io/mildman1848/postgresql`
- Docker Hub: `docker.io/<DOCKERHUB_USERNAME>/postgresql`
- GitLab: `registry.gitlab.com/mildman1848/postgresql`
- Codeberg-compatible registry: `codeberg.org/mildman1848/postgresql`

Publishing is manual through GitHub Actions `workflow_dispatch` with `push=true`.


## Platform support

Current CI builds `linux/amd64` and `linux/arm64`.

`linux/arm/v7` is tracked as a Raspberry Pi compatibility goal, but it is currently blocked by `ghcr.io/linuxserver/baseimage-alpine:3.24` not publishing an `arm/v7` manifest. Do not advertise 32-bit Raspberry Pi support until the selected base image and upstream packages support it.
