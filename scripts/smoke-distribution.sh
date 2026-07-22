#!/usr/bin/env bash
# Local distribution smoke checks (best-effort; CI runs full matrix).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== VPM / local binary =="
if command -v create-vlang-app >/dev/null 2>&1; then
  create-vlang-app --version
  create-vlang-app --help | head -n 5
else
  echo "create-vlang-app not on PATH; building from source..."
  make build
  ./create-vlang-app --version
  ./create-vlang-app --help | head -n 5
fi

echo
echo "== GitHub Release asset probe (optional) =="
VERSION="${1:-0.0.1}"
TAG="create-vlang-app@${VERSION}"
URL="https://github.com/Create-Vlang-App/create-vlang-app/releases/download/${TAG}/create-vlang-app-linux-x86_64"
if curl -sfI "$URL" >/dev/null; then
  echo "Release binary available: $URL"
else
  echo "Release binary not published yet: $URL"
fi

echo
echo "== Docker (optional) =="
if command -v docker >/dev/null 2>&1; then
  if docker pull ulisesjeremias/create-vlang-app:latest >/dev/null 2>&1; then
    docker run --rm ulisesjeremias/create-vlang-app:latest --version
  else
    echo "Docker image not available locally"
  fi
else
  echo "docker not installed — skip"
fi

echo
echo "Smoke script finished (see .github/workflows/smoke-distribution.yml for full CI)."
