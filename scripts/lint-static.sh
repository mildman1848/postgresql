#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail=0

while IFS= read -r -d '' file; do
  case "$file" in
    */dependencies.d/*|*/contents.d/*|*/.gitkeep)
      continue
      ;;
  esac
  if [[ ! -s "$file" ]]; then
    echo "ERROR: empty file: $file" >&2
    fail=1
  fi
done < <(find . -type f \
  ! -path './.git/*' \
  ! -path './secrets/*' \
  ! -path './config/*' \
  ! -path './data/*' \
  ! -path './logs/*' \
  ! -path './sbom/*' \
  -print0)

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

while IFS= read -r -d '' script; do
  mode="$(stat -c '%a' "$script")"
  mode_value=$((8#$mode))
  if [[ ! -x "$script" ]]; then
    echo "ERROR: runtime script is not executable: $script" >&2
    fail=1
  elif (( (mode_value & 0055) != 0055 )); then
    echo "ERROR: runtime script should be readable/executable by abc (use 0755): $script has $mode" >&2
    fail=1
  fi
done < <(find root/usr/local/bin -type f -print0 2>/dev/null || true)

if grep -RIn --exclude-dir=.git --exclude-dir=secrets --exclude-dir=config --exclude-dir=data --exclude-dir=logs --exclude-dir=sbom -i 'm[i]lde' . >/tmp/postgresql-private-term-scan.txt; then
  cat /tmp/postgresql-private-term-scan.txt >&2
  echo "ERROR: forbidden private term found in public artifact" >&2
  fail=1
fi
rm -f /tmp/postgresql-private-term-scan.txt

if command -v hadolint >/dev/null 2>&1; then
  hadolint -c .hadolint.yaml Dockerfile
else
  echo "ERROR: hadolint not installed" >&2
  fail=1
fi

exit "$fail"
