# syntax=docker/dockerfile:1.9
# ubuntu:24.04 matches GitHub Actions ubuntu-latest glibc (release binary needs ≥2.38).
FROM ubuntu:24.04

# VERSION is passed at build time by the publish workflow so the image
# is pinned to a specific GitHub Release (reproducible per tag).
ARG VERSION=latest
# Buildx injects TARGETARCH; default amd64 for plain `docker build`.
ARG TARGETARCH=amd64

# git is required to clone cva-templates during scaffold.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git \
    && rm -rf /var/lib/apt/lists/*

# Retry download: release assets can lag the workflow trigger slightly
# (publish-docker.yml also waits, but CDN edges can still 404 briefly).
RUN set -eux; \
    arch="${TARGETARCH:-amd64}"; \
    case "$arch" in \
      amd64) ASSET=create-vlang-app-linux-x86_64 ;; \
      *) echo "unsupported TARGETARCH=${arch} (need linux-x86_64 release asset)" >&2; exit 1 ;; \
    esac; \
    if [ "$VERSION" = "latest" ]; then \
      TAG=latest; \
      URL="https://github.com/Create-Vlang-App/create-vlang-app/releases/latest/download/${ASSET}"; \
    else \
      TAG="create-vlang-app@${VERSION}"; \
      URL="https://github.com/Create-Vlang-App/create-vlang-app/releases/download/${TAG}/${ASSET}"; \
    fi; \
    attempt=1; \
    until curl -fsSL "$URL" -o /usr/local/bin/create-vlang-app; do \
      if [ "$attempt" -ge 12 ]; then exit 1; fi; \
      echo "download failed (attempt ${attempt}/12); retrying in 15s"; \
      attempt=$((attempt + 1)); \
      sleep 15; \
    done; \
    chmod +x /usr/local/bin/create-vlang-app; \
    create-vlang-app --help >/dev/null

LABEL org.opencontainers.image.version="${VERSION}"

WORKDIR /work
ENTRYPOINT ["create-vlang-app"]
CMD ["--help"]
