# Security Policy

## Supported Scope

This policy covers the PostgreSQL container image, build pipeline, Compose examples, bundled service configuration, and repository automation.

## Reporting Security Vulnerabilities

Please do not open a public issue for a suspected vulnerability.

Use one of these private channels instead:

- GitHub Security Advisories: `https://github.com/mildman1848/postgresql/security/advisories/new`
- If advisories are unavailable, open a normal issue only after removing exploit details and asking for a private follow-up channel.

## What to Include

Please include:

- affected image tag, release, or commit
- host environment and container runtime
- reproduction steps
- expected impact
- mitigation ideas, if available

## Response Targets

We aim to:

- acknowledge reports within 7 business days
- validate severity and scope as quickly as possible
- prioritize critical fixes ahead of normal maintenance work

## Out of Scope

Please report upstream issues to the relevant maintainers when the problem is rooted in:

- PostgreSQL itself, Alpine packages, or the LinuxServer.io base image
- third-party registries or hosting infrastructure
- local host configuration outside this repository's documented examples

## Security Practices

This repository is expected to use:

- Dockerfile linting with Hadolint
- filesystem/container scanning with Trivy
- dependency automation for GitHub Actions and Docker bases
- documented secret-file handling without printing secret values
- protected manual publishing for registry pushes

## Related Documents

- project documentation: [README.md](README.md)
- secret handling notes: `docs/secrets.md` where available

Last updated: 2026-07-15
