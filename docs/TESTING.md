# Testing policy

## Layout

| Module | Tests |
|--------|-------|
| `modules/create_vlang_app_core` | `*_test.v` beside sources |
| `modules/create_vlang_app` | `*_test.v` beside sources |

Run via:

```bash
make test
```

## Expectations

- Every new core/CLI module adds unit tests in the same PR when practical.
- Soft coverage goal: grow toward CNA/CPA thresholds; no hard `%` gate until Epic 6 CI.
- Integration/scaffold tests live under `fixtures/` once Epic 5 lands.

## Smoke

```bash
make build && ./create-vlang-app
```
