# Contributing to create-vlang-app

Thanks for contributing!

## Prerequisites

- [V](https://vlang.io) matching [`.v-version`](.v-version) (`v version`)
- `make`, `git`
- Optional: `pre-commit` (`pre-commit install`)

## Setup

```bash
git clone https://github.com/Create-Vlang-App/create-vlang-app.git
cd create-vlang-app
make test
make build
```

## Workflow

1. Open or use an existing GitHub issue.
2. Branch from `main`: `feat/<issue>-short-slug`.
3. Make a focused change (one issue per PR).
4. Run `make fmt-check vet test build`.
5. Open a **ready-for-review** PR with `Closes #<issue>`.
6. Wait for CI (and AI review if configured) before merging.

## Code style

- Run `v fmt` / `make fmt`.
- Prefer clear names over cleverness.
- English for commits, PRs, and docs.

## VPM

Primary distribution is VPM (`v install create-vlang-app`). Do not assume npm/PyPI workflows.
