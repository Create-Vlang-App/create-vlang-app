# syntax=docker/dockerfile:1
FROM debian:bookworm-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends git make gcc libssl-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN git clone --depth 1 https://github.com/vlang/v /opt/v && cd /opt/v && make
ENV PATH="/opt/v:$PATH"
COPY . .
RUN make build

FROM debian:bookworm-slim
COPY --from=build /src/create-vlang-app /usr/local/bin/create-vlang-app
ENTRYPOINT ["create-vlang-app"]
