.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

SECRET_DIR ?= secrets
SECRET_LENGTH ?= 96
FORCE ?= 0
IMAGE_NAME ?= postgresql-lsio
APP_VERSION ?= 16.14
IMAGE_REVISION ?= mld1
IMAGE_TAG ?= $(APP_VERSION)-$(IMAGE_REVISION)
PLATFORMS ?= linux/amd64,linux/arm64,linux/arm/v7
DOCKER ?= docker

.PHONY: help lint secrets clean-secrets build smoke

help: ## Show this help.
	@echo "Usage: make <target> [VAR=value]"
	@echo ""
	@echo "Targets:"
	@echo "  lint                 Run static checks and hadolint"
	@echo "  secrets              Generate local Docker secret files"

	@echo "  secret-postgresql    Generate PostgreSQL password secret"
	@echo "  clean-secrets        Delete generated local secrets; requires FORCE=1"
	@echo "  build                Build image with Docker Buildx"
	@echo "  smoke                Smoke-test local image"

lint: ## Run static checks and hadolint.
	@scripts/lint-static.sh

secrets: secret-postgresql ## Generate local Docker secret files.

secret-postgresql: ## Generate PostgreSQL password secret.
	@scripts/generate-secret.py --path "$(SECRET_DIR)/postgres_password.txt" --length "$(SECRET_LENGTH)" $(if $(filter 1 true yes,$(FORCE)),--force,)

clean-secrets: ## Delete generated local secrets; requires FORCE=1.
	@if [[ "$(FORCE)" != "1" ]]; then echo "Refusing to delete secrets without FORCE=1" >&2; exit 2; fi
	@rm -rf "$(SECRET_DIR)"

build: ## Build image with Docker Buildx.
	@DOCKER="$(DOCKER)" IMAGE_NAME="$(IMAGE_NAME)" IMAGE_TAG="$(IMAGE_TAG)" APP_VERSION="$(APP_VERSION)" IMAGE_REVISION="$(IMAGE_REVISION)" DOCKERFILE=Dockerfile CONTEXT=. PLATFORMS="$(PLATFORMS)" ./scripts/buildx-build.sh --load

smoke: ## Smoke-test local image.
	@DOCKER="$(DOCKER)" ./smoke-test.sh "$(IMAGE_NAME):$(IMAGE_TAG)"
