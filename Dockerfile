# syntax=docker/dockerfile:1

ARG LSIO_BASE_VERSION=3.24
FROM ghcr.io/linuxserver/baseimage-alpine:${LSIO_BASE_VERSION}

ARG LSIO_BASE_VERSION
ARG BUILD_DATE
ARG APP_VERSION=18.4
ARG IMAGE_REVISION=mldm1
ARG VERSION=18.4-mldm1
ARG VCS_REF
ARG UPSTREAM_PACKAGE=postgresql18

LABEL build_version="Mildman1848 PostgreSQL version:- ${VERSION} Upstream:- ${APP_VERSION} Revision:- ${IMAGE_REVISION} Build-date:- ${BUILD_DATE}" \
      maintainer="Mildman1848" \
      org.opencontainers.image.title="postgresql" \
      org.opencontainers.image.description="PostgreSQL packaged in a LinuxServer.io-style s6 container" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="Mildman1848" \
      org.opencontainers.image.base.name="ghcr.io/linuxserver/baseimage-alpine:${LSIO_BASE_VERSION}" \
      org.opencontainers.image.source="https://github.com/mildman1848/postgresql" \
      org.opencontainers.image.url="https://github.com/mildman1848/postgresql" \
      org.opencontainers.image.licenses="PostgreSQL"

ENV APP_NAME="postgresql" \
    APP_VERSION="${APP_VERSION}" \
    IMAGE_REVISION="${IMAGE_REVISION}" \
    VERSION="${VERSION}" \
    PGDATA="/config/postgresql/data" \
    POSTGRES_DB="postgres" \
    POSTGRES_USER="postgres"

RUN \
  echo "**** install PostgreSQL runtime packages ****" && \
  apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    jq \
    ${UPSTREAM_PACKAGE} \
    ${UPSTREAM_PACKAGE}-client \
    shadow \
    tzdata && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

COPY root/ /

EXPOSE 5432
VOLUME ["/config"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
  CMD /usr/local/bin/healthcheck || exit 1
