# Licensing Notes

## PostgreSQL

Source checked from upstream PostgreSQL `COPYRIGHT` on 2026-07-15.

Observed license text grants permission to use, copy, modify, and distribute the software and documentation for any purpose, provided the copyright notice and warranty disclaimer are preserved.

**Template implication:** PostgreSQL is suitable as a pilot image from a redistribution perspective. Keep upstream copyright/license text in the image docs and repository.

## MariaDB

Source checked from upstream MariaDB Server `COPYING` on 2026-07-15.

Observed license: GNU GPL version 2.

**Template implication:** MariaDB is suitable as a pilot image, but publishing images triggers GPL hygiene:

- keep the license text in the repo/image documentation;
- provide clear source references;
- document package/source versions;
- if we distribute modified MariaDB binaries/scripts tightly coupled to the program, publish the corresponding source changes.

Using Alpine-packaged MariaDB in a container is normally manageable, but we should keep a `NOTICE`/source-reference file per image.

## Base image

LinuxServer.io baseimages are intended for downstream usage but explicitly do not provide a `latest` tag. Pin a release tag and refresh intentionally.

Current inspected LinuxServer.io baseimage-alpine master signal on 2026-07-15:

- Alpine rootfs release: `v3.24`
- s6-overlay in LSIO base Dockerfile: `3.2.1.0`
- upstream s6-overlay latest observed separately: `v3.2.3.1`

**Policy:** use LSIO base tags first; do not manually install a newer s6-overlay over LSIO unless there is a concrete bug or security reason.
