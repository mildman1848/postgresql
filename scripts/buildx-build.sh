#!/usr/bin/env bash
set -euo pipefail

DOCKER="${DOCKER:-docker}"
IMAGE_NAME="${IMAGE_NAME:?Set IMAGE_NAME, e.g. ghcr.io/mildman1848/postgresql}"
IMAGE_TAG="${IMAGE_TAG:-dev}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
CONTEXT="${CONTEXT:-.}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
BUILD_DATE="${BUILD_DATE:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
VCS_REF="${VCS_REF:-$(git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)}"
VERSION="${VERSION:-${IMAGE_TAG}}"
APP_VERSION="${APP_VERSION:-}"
IMAGE_REVISION="${IMAGE_REVISION:-}"
ATTESTATIONS="${ATTESTATIONS:-true}"

extra_args=("$@")
attestation_args=()

has_arg() {
  local needle="$1"
  local arg
  for arg in "${extra_args[@]}"; do
    [[ "$arg" == "$needle" ]] && return 0
  done
  return 1
}

# BuildKit attestations are useful for pushed CI images, but Docker's classic
# local driver cannot attach provenance/SBOM attestations when using --load.
# Keep local developer builds boring and reliable; keep CI/push builds rich.
if [[ "$ATTESTATIONS" == "true" ]] && ! has_arg "--load"; then
  attestation_args+=(--provenance=true --sbom=true)
fi

exec ${DOCKER} buildx build \
  --file "$DOCKERFILE" \
  --platform "$PLATFORMS" \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  --build-arg VERSION="$VERSION" \
  --build-arg APP_VERSION="$APP_VERSION" \
  --build-arg IMAGE_REVISION="$IMAGE_REVISION" \
  --build-arg VCS_REF="$VCS_REF" \
  --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
  "${attestation_args[@]}" \
  "${extra_args[@]}" \
  "$CONTEXT"
