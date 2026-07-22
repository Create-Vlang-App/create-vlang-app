# ADR 0004: Release tag scheme

## Status

Accepted

## Context

CPA/CNA use package-scoped tags (e.g. `create-awesome-python-app@0.2.6`).

## Decision

GitHub Release tags for this CLI use `create-vlang-app@X.Y.Z`. Workflows that still mention only `v*` should prefer the scoped form.

## Consequences

AUR/Homebrew/Docker notify listen for scoped tags / Release events.
