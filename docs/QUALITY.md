# Quality gates

## Required locally and in CI

```bash
make fmt-check   # v fmt -verify (fails on dirty formatting)
make vet         # v vet
make test        # v test in both modules
make build       # produce create-vlang-app binary
```

CI must fail if any of these fail (see workflows under Epic 6).

## Module path

The Makefile creates `.vmodules/create_vlang_app_core` → `modules/create_vlang_app_core` so the CLI can `import create_vlang_app_core` via `VMODULES`.

## pre-commit

```bash
pip install pre-commit   # or uv tool install pre-commit
pre-commit install
pre-commit run --all-files
```

See `.pre-commit-config.yaml`.
