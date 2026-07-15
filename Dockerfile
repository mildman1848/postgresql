# syntax=docker/dockerfile:1

ARG LSIO_BASE_VERSION=3.24
FROM ghcr.io/linuxserver/baseimage-alpine:${LSIO_BASE_VERSION}

ARG BUILD_DATE
ARG VERSION=dev
ARG VCS_REF

LABEL build_version="Mildman1848 PostgreSQL LSIO-style version:- ${VERSION} Build-date:- ${BUILD_DATE}" \
      maintainer="Mildman1848" \
      org.opencontainers.image.title="postgresql-lsio" \
      org.opencontainers.image.description="PostgreSQL packaged in a LinuxServer.io-style s6 container" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.licenses="PostgreSQL"

ENV APP_NAME="postgresql" \
    APP_VERSION="${VERSION}" \
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
    postgresql16 \
    postgresql16-client \
    shadow \
    tzdata && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

COPY root/ /

EXPOSE 5432
VOLUME ["/config"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
  CMD /usr/local/bin/healthcheck || exit 1
