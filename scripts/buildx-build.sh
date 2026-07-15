#!/usr/bin/env bash
set -euo pipefail

DOCKER_BIN="${DOCKER:-docker}"
IMAGE_NAME="${IMAGE_NAME:?Set IMAGE_NAME, e.g. ghcr.io/mildman1848/postgresql-lsio}"
IMAGE_TAG="${IMAGE_TAG:-dev}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
CONTEXT="${CONTEXT:-.}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64,linux/arm/v7}"
BUILD_DATE="${BUILD_DATE:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
VCS_REF="${VCS_REF:-$(git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)}"
VERSION="${VERSION:-${IMAGE_TAG}}"

extra_args=("$@")

exec ${DOCKER_BIN} buildx build   --file "$DOCKERFILE"   --platform "$PLATFORMS"   --build-arg BUILD_DATE="$BUILD_DATE"   --build-arg VERSION="$VERSION"   --build-arg VCS_REF="$VCS_REF"   --tag "${IMAGE_NAME}:${IMAGE_TAG}"   "${extra_args[@]}"   "$CONTEXT"
