# syntax=docker/dockerfile:1.9
FROM debian:bookworm-slim

ARG VERSION=latest

# git is required to clone cva-templates during scaffold.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git \
    && rm -rf /var/lib/apt/lists/*

# Install V toolchain (pin matches .v-version) and build CLI from GitHub tag when VERSION is set.
ARG V_VERSION=0.5.1
RUN curl -fsSL https://github.com/vlang/v/releases/download/${V_VERSION}/v-linux.zip -o /tmp/v.zip \
    && unzip /tmp/v.zip -d /opt/v \
    && ln -sf /opt/v/v /usr/local/bin/v \
    && rm -f /tmp/v.zip

ARG CVA_TAG=create-vlang-app@${VERSION}
RUN set -euo pipefail \
    && if [ "$VERSION" = "latest" ]; then \
        SRC="https://github.com/Create-Vlang-App/create-vlang-app/archive/refs/heads/main.tar.gz"; \
        DIR="create-vlang-app-main"; \
    else \
        SRC="https://github.com/Create-Vlang-App/create-vlang-app/archive/refs/tags/${CVA_TAG}.tar.gz"; \
        DIR="create-vlang-app-${CVA_TAG}"; \
    fi \
    && curl -fsSL "$SRC" -o /tmp/cva.tar.gz \
    && tar xzf /tmp/cva.tar.gz -C /tmp \
    && cd "/tmp/${DIR}" \
    && mkdir -p .vmodules \
    && ln -sfn "$PWD/modules/create_vlang_app_core" .vmodules/create_vlang_app_core \
    && cd modules/create_vlang_app \
    && VMODULES="/tmp/${DIR}/.vmodules" v -prod -o /usr/local/bin/create-vlang-app . \
    && rm -rf /tmp/cva.tar.gz "/tmp/${DIR}"

WORKDIR /work
ENTRYPOINT ["create-vlang-app"]
CMD ["--help"]
