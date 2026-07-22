# syntax=docker/dockerfile:1.9
FROM debian:bookworm-slim AS build

ARG V_VERSION=0.5.1

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl git make gcc libssl-dev unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN curl -fsSL "https://github.com/vlang/v/releases/download/${V_VERSION}/v-linux.zip" -o /tmp/v.zip \
    && unzip /tmp/v.zip -d /opt/v \
    && ln -sf /opt/v/v /usr/local/bin/v \
    && rm -f /tmp/v.zip

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
