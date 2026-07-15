.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

SECRET_DIR ?= secrets
SECRET_LENGTH ?= 96
FORCE ?= 0
IMAGE_NAME ?= postgresql
APP_VERSION ?= 16.14
IMAGE_REVISION ?= mld1
IMAGE_TAG ?= $(APP_VERSION)-$(IMAGE_REVISION)
PLATFORMS ?= linux/amd64,linux/arm64
DOCKER ?= docker
COMPOSE ?= $(DOCKER) compose
TRIVY ?= trivy
SYFT ?= syft
UPSTREAM_PACKAGE ?= postgresql16
LSIO_BASE_IMAGE ?= ghcr.io/linuxserver/baseimage-alpine:3.24
SBOM_FORMAT ?= spdx-json
SBOM_OUT ?= $(IMAGE_NAME)-$(IMAGE_TAG).sbom.json
TRIVY_SEVERITY ?= HIGH,CRITICAL

.PHONY: help setup check-tools info version lint secrets secret-postgresql clean-secrets build smoke labels scan sbom check-upstream release-dry-run compose-up compose-down logs shell clean-images clean

help: ## Show this help.
	@echo "Usage: make <target> [VAR=value]"
	@echo ""
	@echo "Core targets:"
	@echo "  setup                Install/check local build helper tools"
	@echo "  check-tools          Verify required local commands"
	@echo "  info                 Print image/build metadata"
	@echo "  version              Print combined image version"
	@echo "  lint                 Run static checks and hadolint"
	@echo "  secrets              Generate local Docker secret files"
	@echo "  build                Build image with Docker Buildx (--load)"
	@echo "  smoke                Smoke-test local image"
	@echo "  labels               Inspect OCI labels of local image"
	@echo "  scan                 Run local Trivy image scan"
	@echo "  sbom                 Generate local SBOM with Syft"
	@echo "  check-upstream       Print upstream/base version signals"
	@echo "  release-dry-run      Show image tags/labels without publishing"
	@echo "  compose-up           Start docker-compose example"
	@echo "  compose-down         Stop docker-compose example"
	@echo "  shell                Open debug shell in image"
	@echo "  clean-images         Remove local image; requires FORCE=1"

setup: ## Install/check local build helper tools.
	@scripts/setup-tools.sh

check-tools: ## Verify required local commands.
	@missing=0; \
	for cmd in git curl jq hadolint actionlint $(DOCKER); do \
	  if ! command -v "$${cmd}" >/dev/null 2>&1; then echo "ERROR: missing $${cmd}" >&2; missing=1; else echo "OK: $${cmd} -> $$(command -v $${cmd})"; fi; \
	done; \
	if ! command -v $(firstword $(TRIVY)) >/dev/null 2>&1; then echo "WARN: trivy missing; run make setup for scan target" >&2; fi; \
	if ! command -v $(firstword $(SYFT)) >/dev/null 2>&1; then echo "WARN: syft missing; run make setup for sbom target" >&2; fi; \
	exit "$${missing}"

info: ## Print image/build metadata.
	@printf 'IMAGE_NAME=%s\n' "$(IMAGE_NAME)"
	@printf 'APP_VERSION=%s\n' "$(APP_VERSION)"
	@printf 'IMAGE_REVISION=%s\n' "$(IMAGE_REVISION)"
	@printf 'IMAGE_TAG=%s\n' "$(IMAGE_TAG)"
	@printf 'PLATFORMS=%s\n' "$(PLATFORMS)"
	@printf 'LSIO_BASE_IMAGE=%s\n' "$(LSIO_BASE_IMAGE)"
	@printf 'UPSTREAM_PACKAGE=%s\n' "$(UPSTREAM_PACKAGE)"

version: ## Print combined image version.
	@printf '%s\n' "$(IMAGE_TAG)"

lint: ## Run static checks and hadolint.
	@scripts/lint-static.sh

secrets: secret-postgresql ## Generate local Docker secret files.

secret-postgresql: ## Generate PostgreSQL password secret.
	@scripts/generate-secret.py --path "$(SECRET_DIR)/postgres_password.txt" --length "$(SECRET_LENGTH)" $(if $(filter 1 true yes,$(FORCE)),--force,)

clean-secrets: ## Delete generated local secrets; requires FORCE=1.
	@if [[ "$(FORCE)" != "1" ]]; then echo "Refusing to delete secrets without FORCE=1" >&2; exit 2; fi
	@find "$(SECRET_DIR)" -type f ! -name .gitkeep -delete

build: ## Build image with Docker Buildx.
	@DOCKER="$(DOCKER)" IMAGE_NAME="$(IMAGE_NAME)" IMAGE_TAG="$(IMAGE_TAG)" APP_VERSION="$(APP_VERSION)" IMAGE_REVISION="$(IMAGE_REVISION)" VERSION="$(IMAGE_TAG)" DOCKERFILE=Dockerfile CONTEXT=. PLATFORMS="$(PLATFORMS)" ./scripts/buildx-build.sh --load

smoke: ## Smoke-test local image.
	@DOCKER="$(DOCKER)" ./smoke-test.sh "$(IMAGE_NAME):$(IMAGE_TAG)"

labels: ## Inspect OCI labels of local image.
	@$(DOCKER) image inspect "$(IMAGE_NAME):$(IMAGE_TAG)" --format '{{json .Config.Labels}}' | jq .

scan: ## Run local Trivy image scan.
	@if ! command -v $(firstword $(TRIVY)) >/dev/null 2>&1; then echo "ERROR: trivy not installed. Run: make setup" >&2; exit 2; fi
	@$(TRIVY) image --severity "$(TRIVY_SEVERITY)" --exit-code 0 "$(IMAGE_NAME):$(IMAGE_TAG)"

sbom: ## Generate local SBOM with Syft.
	@if ! command -v $(firstword $(SYFT)) >/dev/null 2>&1; then echo "ERROR: syft not installed. Run: make setup" >&2; exit 2; fi
	@$(SYFT) "$(IMAGE_NAME):$(IMAGE_TAG)" -o "$(SBOM_FORMAT)=$(SBOM_OUT)"
	@echo "Wrote $(SBOM_OUT)"

check-upstream: ## Print upstream/base version signals.
	@echo "Base image: $(LSIO_BASE_IMAGE)"
	@$(DOCKER) buildx imagetools inspect "$(LSIO_BASE_IMAGE)" | sed -n '1,80p'
	@echo ""
	@echo "Alpine package signal for $(UPSTREAM_PACKAGE):"
	@$(DOCKER) run --rm alpine:3.24 sh -c 'apk update >/dev/null && apk search -x "$(UPSTREAM_PACKAGE)"'
	@echo "Upstream: https://www.postgresql.org/"

release-dry-run: ## Show image tags/labels without publishing.
	@echo "Would publish:"
	@echo "  ghcr.io/<owner>/$(IMAGE_NAME):$(IMAGE_TAG)"
	@echo "  ghcr.io/<owner>/$(IMAGE_NAME):latest"
	@echo "  ghcr.io/<owner>/$(IMAGE_NAME):sha-<gitsha>"
	@echo "Build args:"
	@echo "  APP_VERSION=$(APP_VERSION)"
	@echo "  IMAGE_REVISION=$(IMAGE_REVISION)"
	@echo "  VERSION=$(IMAGE_TAG)"
	@echo "  PLATFORMS=$(PLATFORMS)"

compose-up: secrets ## Start docker-compose example.
	@IMAGE_NAME="$(IMAGE_NAME)" IMAGE_TAG="$(IMAGE_TAG)" $(COMPOSE) up -d

compose-down: ## Stop docker-compose example.
	@$(COMPOSE) down --remove-orphans

logs: ## Show compose service logs.
	@$(COMPOSE) logs --tail=200

shell: ## Open debug shell in local image.
	@$(DOCKER) run --rm -it --entrypoint /bin/bash "$(IMAGE_NAME):$(IMAGE_TAG)"

clean-images: ## Remove local image; requires FORCE=1.
	@if [[ "$(FORCE)" != "1" ]]; then echo "Refusing to remove images without FORCE=1" >&2; exit 2; fi
	@$(DOCKER) image rm "$(IMAGE_NAME):$(IMAGE_TAG)" || true

clean: ## Remove local temporary artifacts.
	@rm -rf .tmp
