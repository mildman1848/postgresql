# Proposed Make Targets

These targets are implemented/recommended for all image repositories. The current image repositories implement the high-value targets listed below. The template repository implements setup, check-tools, lint, secret, and clean.

## High-value next targets

| Target | Purpose | Notes |
|---|---|---|
| `make info` | Print image name, upstream version, image revision, platforms, and registry targets. | Safe default for humans and CI logs. |
| `make version` | Print only the combined image version, e.g. `16.14-mld1`. | Useful for scripts and release notes. |
| `make labels` | Inspect built image OCI labels. | Verifies version/base/source metadata. |
| `make scan` | Run local Trivy image scan. | Should not require registry push. |
| `make sbom` | Generate an SBOM artifact locally. | Prefer SPDX or CycloneDX. |
| `make shell` | Start an interactive shell in the built image. | Debug-only; never in CI. |
| `make logs` | Show logs from the last smoke-test container. | Useful when smoke fails. |
| `make compose-up` | Start the included Compose example. | Local operator convenience. |
| `make compose-down` | Stop the included Compose example. | Keep cleanup easy. |
| `make clean-images` | Remove local test images. | Require `FORCE=1`. |
| `make check-upstream` | Print current upstream package/base version signals. | Feeds release/changelog work. |
| `make release-dry-run` | Show tags/labels that would be published. | Safety before registry push. |

## Recommendation

Implement next in this order:

1. `info` and `version`
2. `labels`
3. `scan`
4. `check-upstream`
5. `release-dry-run`
6. Compose/debug helpers

Do not add a full release automation target until GHCR/Docker Hub publishing has been verified with manual `workflow_dispatch` first.


## Socket permissions

If images were built with `sudo docker`, run scan/SBOM helpers with matching privileges:

```bash
make scan TRIVY='sudo trivy'
make sbom SYFT='sudo syft'
```

If your user is allowed to access the Docker socket directly, the defaults are enough:

```bash
make scan
make sbom
```
