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
make env-setup
make validate
make build DOCKER='sudo docker'
make smoke DOCKER='sudo docker'
make security-scan DOCKER='sudo docker' TRIVY='sudo trivy'
make sbom DOCKER='sudo docker' SYFT='sudo syft'
make start DOCKER='sudo docker'
make logs DOCKER='sudo docker'
```

## Description

PostgreSQL packaged in a LinuxServer.io-style s6 container.

This repository builds the `postgresql` container image. It uses a LinuxServer.io-style runtime, s6-overlay supervision, `/config` persistence, secure local secret generation, and CI-based multi-platform builds.

## Versioning

This image follows the template versioning format:

```text
<upstream-version>-mldm<N>
```

Current image version:

```text
18.4-mldm2
```

- Upstream application/package version: `18.4`
- Image revision: `mldm2`

## Local development helpers

```bash
make setup          # install/check hadolint, actionlint, trivy, syft
make info           # print image metadata
make build          # build local image
make smoke          # run smoke test
make scan           # run Trivy scan
make sbom           # generate local SBOM
make check-upstream # show base image and package signals
```

Use `TRIVY='sudo trivy'` and `SYFT='sudo syft'` if your Docker images are only visible through `sudo docker`.

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
- `docs/branding.md` — public branding rules and startup banner.

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
