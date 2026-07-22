# Troubleshooting

## `import create_vlang_app_core` fails locally

Run via `make build` / `make test` so `.vmodules` is linked. See `Makefile` `ensure-vmodules`.

## Wrong V version

Check `.v-version` and `v version`. Use `vlang/setup-v` with `version-file` in CI.

## Cache / offline scaffolding

Reserved for `CVA_CACHE_DIR` / `--offline` once the engine lands (Epic 3–4).
