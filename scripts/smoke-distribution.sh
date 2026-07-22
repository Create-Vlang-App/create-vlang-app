#!/usr/bin/env bash
set -euo pipefail
echo "== binary =="
make build
./create-vlang-app --version
echo "== fixture scaffold =="
./create-vlang-app /tmp/cva-dist-smoke --template minimal --addons github-setup --fixture --no-interactive --force --no-install
test -f /tmp/cva-dist-smoke/v.mod
echo "== optional channels (skip if unavailable) =="
if command -v v >/dev/null; then
  v install create-vlang-app 2>/dev/null && create-vlang-app --version || echo "VPM not yet registered — skipped"
fi
docker pull ulisesjeremias/create-vlang-app:latest 2>/dev/null || echo "Docker image not published — skipped"
echo "dist smoke OK (required paths passed)"
