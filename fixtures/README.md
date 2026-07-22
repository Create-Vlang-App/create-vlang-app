# Fixtures

Offline catalog and layers for CI / local tests.

| Path | Purpose |
|------|---------|
| `catalog/templates.json` | Stub catalog with `minimal` + `github-setup` pointing at core testdata layers |
| (layers) | `modules/create_vlang_app_core/testdata/layers/` |

```bash
create-vlang-app /tmp/x --template minimal --catalog-path fixtures/catalog/templates.json --no-interactive --force --no-install
```
