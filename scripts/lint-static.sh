#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail=0

while IFS= read -r -d '' file; do
  case "$file" in
    */dependencies.d/*|*/contents.d/*)
      continue
      ;;
  esac
  if [[ ! -s "$file" ]]; then
    echo "ERROR: empty file: $file" >&2
    fail=1
  fi
done < <(find . -type f ! -path './.git/*' ! -path './secrets/*' -print0)

while IFS= read -r -d '' service_dir; do
  name="$(basename "$service_dir")"
  [[ "$name" == "user" || "$name" == "dependencies.d" || "$name" == "contents.d" ]] && continue
  if [[ ! -f "$service_dir/type" ]]; then
    echo "ERROR: missing type in $service_dir" >&2
    fail=1
    continue
  fi
  type_value="$(cat "$service_dir/type" 2>/dev/null || true)"
  case "$type_value" in
    oneshot)
      [[ -f "$service_dir/up" || -f "$service_dir/run" ]] || { echo "ERROR: oneshot without up/run: $service_dir" >&2; fail=1; }
      ;;
    longrun)
      [[ -x "$service_dir/run" ]] || { echo "ERROR: longrun without executable run: $service_dir" >&2; fail=1; }
      ;;
    bundle)
      ;;
    *)
      echo "ERROR: unknown s6 type '$type_value' in $service_dir" >&2
      fail=1
      ;;
  esac
done < <(find root/etc/s6-overlay/s6-rc.d -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null || true)

if command -v hadolint >/dev/null 2>&1; then
  hadolint -c .hadolint.yaml Dockerfile
else
  echo "ERROR: hadolint not installed" >&2
  fail=1
fi

exit "$fail"
