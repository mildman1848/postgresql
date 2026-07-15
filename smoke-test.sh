#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: smoke-test.sh IMAGE}"
name="postgresql-smoke-$$"
tmpdir="$(mktemp -d)"
trap '${DOCKER:-docker} rm -f "$name" >/dev/null 2>&1 || true; rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/config"
printf 'change-me-in-production' > "$tmpdir/password"

${DOCKER:-docker} run -d --name "$name"   -e PUID="$(id -u)"   -e PGID="$(id -g)"   -e POSTGRES_DB=smoke   -e FILE__POSTGRES_PASSWORD=/run/secrets/postgres_password   -v "$tmpdir/config:/config"   -v "$tmpdir/password:/run/secrets/postgres_password:ro"   "$image"

for _ in {1..60}; do
  if ${DOCKER:-docker} exec "$name" /usr/local/bin/healthcheck >/dev/null 2>&1; then
    echo "PostgreSQL smoke test passed"
    exit 0
  fi
  sleep 2
done

${DOCKER:-docker} logs "$name"
exit 1
