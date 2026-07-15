# Branding

This image uses the public `Mildman1848` namespace/brand.

## Rules

- `Mildman1848` is allowed in public image metadata, repository links, logs, and documentation.
- Private household terms must not appear in public artifacts.
- Startup branding is limited to a small ASCII banner plus runtime metadata.
- Do not print secrets or environment values in branding output.

## Startup banner

The s6 `init-branding` oneshot prints a compact ASCII banner and basic runtime metadata:

```text
Mildman1848
Brand: Mildman1848
Image: <app> <version>
Runtime: LinuxServer.io-style s6-overlay container
User: abc via PUID/PGID after initialization
```
