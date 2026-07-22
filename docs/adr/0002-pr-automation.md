# ADR 0002: PR automation — CodeRabbit-only

- **Status:** Accepted
- **Date:** 2026-07-21
- **Issue:** #70

## Context

CNA uses Danger.js in some repos; CPA chose CodeRabbit-only via ADR.

## Decision

Use **CodeRabbit-only** (no Danger.js) for create-vlang-app until a clear need for custom Danger rules appears.

## Consequences

- Less Node tooling in a V repo.
- Rely on GitHub Actions + CodeRabbit comments for review automation.
