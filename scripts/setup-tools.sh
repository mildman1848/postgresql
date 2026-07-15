#!/usr/bin/env bash
set -euo pipefail

install_dir="${INSTALL_DIR:-/usr/local/bin}"
hadolint_version="${HADOLINT_VERSION:-v2.14.0}"
actionlint_version="${ACTIONLINT_VERSION:-v1.7.12}"
trivy_version="${TRIVY_VERSION:-v0.72.0}"
syft_version="${SYFT_VERSION:-v1.46.0}"

need_sudo=()
if [[ ! -w "$install_dir" ]]; then
  need_sudo=(sudo)
fi

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: missing required command '$1'" >&2
    exit 2
  fi
}

require curl
require tar
require sha256sum

install_hadolint() {
  if command -v hadolint >/dev/null 2>&1; then
    echo "OK: $(hadolint --version)"
    return
  fi
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN
  base="https://github.com/hadolint/hadolint/releases/download/${hadolint_version}"
  curl -fsSL "$base/hadolint-linux-x86_64" -o "$tmp/hadolint-linux-x86_64"
  curl -fsSL "$base/hadolint-linux-x86_64.sha256" -o "$tmp/hadolint-linux-x86_64.sha256"
  (cd "$tmp" && sha256sum -c hadolint-linux-x86_64.sha256)
  "${need_sudo[@]}" install -m 0755 "$tmp/hadolint-linux-x86_64" "$install_dir/hadolint"
}

install_actionlint() {
  if command -v actionlint >/dev/null 2>&1; then
    echo "OK: actionlint $(actionlint -version 2>/dev/null | head -1)"
    return
  fi
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN
  version="${actionlint_version#v}"
  curl -fsSL "https://github.com/rhysd/actionlint/releases/download/v${version}/actionlint_${version}_linux_amd64.tar.gz" -o "$tmp/actionlint.tar.gz"
  tar -xzf "$tmp/actionlint.tar.gz" -C "$tmp" actionlint
  "${need_sudo[@]}" install -m 0755 "$tmp/actionlint" "$install_dir/actionlint"
}

install_trivy() {
  if command -v trivy >/dev/null 2>&1; then
    echo "OK: $(trivy --version | head -1)"
    return
  fi
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN
  version="${trivy_version#v}"
  curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${version}/trivy_${version}_Linux-64bit.tar.gz" -o "$tmp/trivy.tar.gz"
  tar -xzf "$tmp/trivy.tar.gz" -C "$tmp" trivy
  "${need_sudo[@]}" install -m 0755 "$tmp/trivy" "$install_dir/trivy"
}

install_syft() {
  if command -v syft >/dev/null 2>&1; then
    echo "OK: syft $(syft version -o json 2>/dev/null | jq -r .version 2>/dev/null || syft version | head -1)"
    return
  fi
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN
  version="${syft_version#v}"
  curl -fsSL "https://github.com/anchore/syft/releases/download/v${version}/syft_${version}_linux_amd64.tar.gz" -o "$tmp/syft.tar.gz"
  tar -xzf "$tmp/syft.tar.gz" -C "$tmp" syft
  "${need_sudo[@]}" install -m 0755 "$tmp/syft" "$install_dir/syft"
}

install_hadolint
install_actionlint
install_trivy
install_syft

for cmd in git jq docker; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd -> $(command -v "$cmd")"
  else
    echo "WARN: $cmd is missing. Install it with your OS package manager." >&2
  fi
done
