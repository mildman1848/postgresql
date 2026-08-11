# Changelog

All notable changes to this image are documented in this file.

## Unreleased

### Added

- Initial image version `18.4-mldm1` using upstream `18.4`.
- Initial LinuxServer.io-style s6-overlay image for PostgreSQL.
- Local `make` workflow for secure secret generation, linting, building, and smoke testing.
- GitHub Actions for linting, Docker build, security scanning, Dependabot, and upstream monitoring.
- Optional registry target preparation for GHCR, Docker Hub, GitLab, and Codeberg-compatible registries.

### Security

- Generated secrets are 96 alphanumeric characters by default, written with mode `0600`, and contain no trailing newline.

## Versioning

Image tags follow `<upstream-version>-mldm<N>`. Packaging-only updates increment the `mldm<N>` suffix.
