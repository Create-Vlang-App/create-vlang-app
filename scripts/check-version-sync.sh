#!/usr/bin/env bash
# Verify semver is consistent across v.mod files, CLI constants, and an optional tag.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

read_vmod_version() {
  local file="$1"
  sed -n "s/^[[:space:]]*version:[[:space:]]*'\([^']*\)'.*/\1/p" "$file" | head -n1
}

read_const_version() {
  local file="$1"
  local name="$2"
  sed -n "s/^pub const ${name} = '\([^']*\)'.*/\1/p" "$file" | head -n1
}

read_app_version() {
  sed -n "s/^const app_version = '\([^']*\)'.*/\1/p" modules/create_vlang_app/main.v | head -n1
}

VERSIONS=(
  "$(read_vmod_version v.mod)"
  "$(read_vmod_version modules/create_vlang_app/v.mod)"
  "$(read_vmod_version modules/create_vlang_app_core/v.mod)"
  "$(read_const_version modules/create_vlang_app_core/create_vlang_app_core.v version)"
  "$(read_app_version)"
)

EXPECTED="${1:-${VERSIONS[0]}}"
for v in "${VERSIONS[@]}"; do
  if [[ "$v" != "$EXPECTED" ]]; then
    echo "::error::Version mismatch: expected ${EXPECTED}, found ${v}" >&2
    exit 1
  fi
done

if [[ -n "${TAG:-}" ]]; then
  TAG_VERSION="${TAG#create-vlang-app@}"
  if [[ "$TAG_VERSION" != "$EXPECTED" ]]; then
    echo "::error::Tag ${TAG} does not match module version ${EXPECTED}" >&2
    exit 1
  fi
fi

echo "Version sync OK: ${EXPECTED}"
