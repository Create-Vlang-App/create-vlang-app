#!/usr/bin/env bash
set -euo pipefail
if ! command -v v >/dev/null 2>&1; then
  git clone --depth 1 https://github.com/vlang/v /tmp/vlang-v
  (cd /tmp/vlang-v && make && ./v symlink)
fi
v version
make test || true
