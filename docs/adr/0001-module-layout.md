# ADR 0001: Multi-module layout for create-vlang-app

- **Status:** Accepted
- **Date:** 2026-07-21
- **Issue:** Create-Vlang-App/create-vlang-app#3

## Context

Create-Node-App uses npm workspaces (`packages/*`). Create-Python-App uses uv workspaces.
V has no equivalent workspace tool. We need a layout that:

1. Supports two publishable units: `create-vlang-app-core` (library) and `create-vlang-app` (CLI).
2. Works with `v test`, `v fmt`, `v vet`, and VPM.
3. Avoids breaking V module resolution (see vsl/vtl/`~/.vmodules` patterns).

## Decision

Use a **root meta-repo** with modules under `modules/`:

```text
create-vlang-app/                 # git root
  v.mod                           # workspace meta (name: create_vlang_app_workspace)
  .v-version                      # pin for vlang/setup-v
  modules/
    create_vlang_app_core/        # library engine (VPM: create-vlang-app-core)
      v.mod
      src/                        # or flat .v files per V conventions
    create_vlang_app/             # CLI binary (VPM: create-vlang-app)
      v.mod
      src/
  fixtures/                       # offline catalog for tests (later)
  docs/
  Makefile
```

### Naming

| Path / module | VPM / binary name |
|---------------|-------------------|
| `modules/create_vlang_app_core` | `create-vlang-app-core` |
| `modules/create_vlang_app` | `create-vlang-app` |

V module identifiers use underscores; distribution names use hyphens (parity with CNA/CPA display names).

### Build & test

- From each module directory: `v test .`, `v fmt -verify .`, `v vet .`
- Root `Makefile` orchestrates both modules.
- CLI depends on core via relative path or VPM once published.

## Consequences

- **Positive:** Clear separation CLI vs engine; mirrors CNA/CPA package split; fits VPM.
- **Negative:** No single `v test` at root without Makefile; contributors must learn two `v.mod` files.
- **Rejected alternatives:**
  - Single flat module (harder to publish core separately).
  - Emulating npm workspaces with scripts only (no ADR clarity).
  - Putting modules in `packages/` (Node-centric name; `modules/` is clearer for V).

## References

- knowledge/create-vlang-app-parity-matrix.md (workspace)
- Create-Python-App docs/adr/0001-uv-workspaces.md
- ulises-jeremias/rxv `v.mod` + `subdirs`
- vlang/vsl, vlang/vtl module layout
