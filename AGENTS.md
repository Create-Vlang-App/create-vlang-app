# AGENTS.md — create-vlang-app

## Purpose

V-native scaffolding CLI (`create-vlang-app`) and engine (`create-vlang-app-core`).

## Hard rules

1. **V-native only** — do not introduce Node/Python as the scaffolding runtime without an ADR.
2. **Issue-first** — every significant change links a GitHub issue (`Closes #N`).
3. **One fix per PR** — ready for review (no drafts unless requested).
4. **English** for commits, PRs, issues, and docs.
5. **Never commit directly to `main`** (except empty-repo bootstrap).
6. **Never leave `main` red.**
7. Prefer minimal diffs.

## Layout

See `docs/adr/0001-module-layout.md`. Modules live under `modules/`.

## Commands

```bash
make test
make fmt-check
make vet
make build
```

## References

- Roadmap: <https://github.com/Create-Vlang-App/create-vlang-app/issues/1>
- Parity matrix (workspace): `knowledge/create-vlang-app-parity-matrix.md`
- Process: `knowledge/processes/create-vlang-app-maintenance.md`
