# Registry Publishing and Git Mirrors

Publishing and mirroring are separate concerns.

## Git mirrors

This repository mirrors Git state from GitHub to Codeberg and GitLab via `.github/workflows/mirror.yml`.

Required GitHub repository secrets:

```text
CODEBERG_MIRROR_SSH_KEY
GITLAB_MIRROR_SSH_KEY
```

These are private SSH keys used only by the mirror workflow. Do not print them, commit them, or reuse them as application secrets.

## Container registries

| Registry | Status | Image pattern |
|---|---|---|
| GHCR | prepared | `ghcr.io/mildman1848/postgresql` |
| Docker Hub | prepared when `DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN` exist | `docker.io/<DOCKERHUB_USERNAME>/postgresql` |
| GitLab Registry | optional | `registry.gitlab.com/mildman1848/postgresql` |
| Codeberg/Forgejo Registry | optional, verify exact package path before first push | `codeberg.org/mildman1848/postgresql` |

## Registry secrets

Docker Hub:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

GitLab Registry:

```text
GITLAB_REGISTRY_USER
GITLAB_REGISTRY_TOKEN
```

Codeberg/Forgejo Registry:

```text
CODEBERG_REGISTRY_USER
CODEBERG_REGISTRY_TOKEN
```

## Safety policy

- Pull requests build but do not push.
- Manual `workflow_dispatch` with `push=true` is required for publishing.
- Local lint/build/smoke/security checks must pass before registry push.
- Git mirrors may run automatically after pushes to `main` because they copy Git state only; registry publishing creates public artifacts and stays explicit.
