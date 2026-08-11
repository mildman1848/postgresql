# Versioning

This image uses an LSIO-inspired combined version: preserve the upstream PostgreSQL package version and add a local packaging revision.

```text
<upstream-version>-mldm<N>
```

Current version:

```text
18.4-mldm2
```

## Components

| Component | Meaning |
|---|---|
| `18.4` | PostgreSQL upstream/package version from Alpine `postgresql18`. |
| `mldm2` | Local image packaging revision for this packaged image. |

`Mildman1848` is allowed as the public namespace/brand. Private household names must not appear in public artifacts.

## Bump rules

- Upstream package/application changes: bump `<upstream-version>` and reset to `mldm1`.
- Packaging-only changes with the same upstream version: increment `mldm<N>`.
- Security/baseimage-only rebuild that creates a republished artifact: increment `mldm<N>`.

## Labels

The image exposes:

```text
org.opencontainers.image.version=18.4-mldm2
IMAGE_REVISION=mldm2
APP_VERSION=18.4
VERSION=18.4-mldm2
```

Do not use shortened legacy variants of the packaging suffix. The project standard is explicitly `mldm<N>`.
