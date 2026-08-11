#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: smoke-test.sh IMAGE}"
name="postgresql-smoke-$$"
tmpdir="$(mktemp -d)"
DOCKER_BIN="${DOCKER:-docker}"
password="change-me-in-production-$RANDOM-$$"

cleanup() {
  ${DOCKER_BIN} rm -f "$name" >/dev/null 2>&1 || true
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$tmpdir/config"
printf '%s' "$password" > "$tmpdir/password"
chmod 600 "$tmpdir/password"

${DOCKER_BIN} run -d --name "$name" \
  -e PUID="$(id -u)" \
  -e PGID="$(id -g)" \
  -e POSTGRES_DB=smoke \
  -e POSTGRES_USER=postgres \
  -e FILE__POSTGRES_PASSWORD=/run/secrets/postgres_password \
  -v "$tmpdir/config:/config" \
  -v "$tmpdir/password:/run/secrets/postgres_password:ro" \
  "$image"

for _ in {1..60}; do
  if ${DOCKER_BIN} exec "$name" /usr/local/bin/healthcheck >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

${DOCKER_BIN} exec "$name" /usr/local/bin/healthcheck >/dev/null

${DOCKER_BIN} exec \
  -e PGPASSWORD="$password" \
  "$name" \
  psql -h 127.0.0.1 -p 5432 -U postgres -d smoke -tAc 'SELECT 1;' | grep -qx '1'

${DOCKER_BIN} exec \
  -e PGPASSWORD="$password" \
  "$name" \
  psql -h 127.0.0.1 -p 5432 -U postgres -d smoke -tAc "SELECT name FROM pg_available_extensions WHERE name = 'vector';" | grep -qx 'vector'

if ${DOCKER_BIN} exec \
  -e PGPASSWORD='deliberately-wrong-password' \
  "$name" \
  psql -h 127.0.0.1 -p 5432 -U postgres -d smoke -tAc 'SELECT 1;' >/dev/null 2>&1; then
  echo 'ERROR: PostgreSQL accepted a deliberately wrong password' >&2
  exit 1
fi

process_users="$(${DOCKER_BIN} exec "$name" sh -lc "ps aux | awk '\$11 ~ /^postgres/ {print \$1}' | sort -u")"
if [[ -z "$process_users" ]]; then
  echo 'ERROR: no PostgreSQL process found' >&2
  ${DOCKER_BIN} logs "$name" >&2 || true
  exit 1
fi
if grep -qx 'root' <<<"$process_users"; then
  echo 'ERROR: PostgreSQL process is running as root' >&2
  exit 1
fi
if ! grep -qx 'abc' <<<"$process_users"; then
  echo "ERROR: PostgreSQL process did not run as abc; observed: $process_users" >&2
  exit 1
fi

if ${DOCKER_BIN} logs "$name" 2>&1 | grep -F "$password" >/dev/null; then
  echo 'ERROR: generated PostgreSQL secret leaked into container logs' >&2
  exit 1
fi

echo 'PostgreSQL smoke test passed: health, auth, wrong-password rejection, abc process user, no secret leak'
