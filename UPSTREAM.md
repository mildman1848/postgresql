# Upstream Notes

## Upstream project

- Name: PostgreSQL
- URL: https://www.postgresql.org/
- License: PostgreSQL License / permissive redistribution terms.

## Packaging approach

This image uses Alpine packages installed into `ghcr.io/linuxserver/baseimage-alpine:3.24` instead of copying from the official upstream container image.

Reasoning:

1. The LinuxServer.io baseimage already provides s6-overlay v3, `abc`, `/config`, `PUID`, `PGID`, and related runtime conventions.
2. Alpine packages avoid libc/runtime mismatch risks that can happen when copying binaries from unrelated upstream images.
3. The image remains small, auditable, and easy to monitor through Alpine package metadata.

## Divergence from official upstream images

- Runtime supervision is provided by s6-overlay v3.
- Persistent data lives under `/config`.
- Secrets can be mounted through `FILE__*` environment variables.
- The main process runs as the LSIO-style `abc` user after initialization.

## Update tracking

Upstream status is tracked by `.github/workflows/upstream-monitor.yml`.

Manual checks:

```bash
docker run --rm alpine:3.24 sh -c 'apk update >/dev/null && apk info -v postgresql16'
```

## Current tracked version

- Upstream version: `16.14`
- Image revision: `milde1`
- Combined image version: `16.14-milde1`

Packaging-only changes should increment the image revision while keeping the upstream version unchanged.
