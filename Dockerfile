# syntax=docker/dockerfile:1.9
FROM debian:bookworm-slim AS build

# TARGETARCH is injected by Buildx (amd64 / arm64).
ARG TARGETARCH
ARG V_VERSION=0.5.2

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl git make gcc libssl-dev unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
# V release assets use underscores: v_linux.zip / v_linux_arm64.zip (not v-linux.zip).
RUN case "${TARGETARCH}" in \
      amd64|"") V_ZIP=v_linux.zip ;; \
      arm64) V_ZIP=v_linux_arm64.zip ;; \
      *) echo "unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL "https://github.com/vlang/v/releases/download/${V_VERSION}/${V_ZIP}" -o /tmp/v.zip \
    && unzip /tmp/v.zip -d /opt \
    && ln -sf /opt/v/v /usr/local/bin/v \
    && rm -f /tmp/v.zip \
    && v version

COPY . .
RUN make build

FROM debian:bookworm-slim

ARG VERSION=0.0.1

# git is required to clone cva-templates during scaffold.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/create-vlang-app /usr/local/bin/create-vlang-app

LABEL org.opencontainers.image.version="${VERSION}"

WORKDIR /work
ENTRYPOINT ["create-vlang-app"]
CMD ["--help"]
