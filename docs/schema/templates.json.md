# `templates.json` schema (CVA)

Parity target: Create-Node-App `cna-templates` / Create-Python-App `cpa-templates` catalogs.

## Root object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `templates` | array of Entry | yes | Base project templates |
| `addons` | array of Entry | yes | Optional extension layers (CPA/CNA “extensions”) |

## Entry

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Slug used by `--template` / `--addons` |
| `description` | string | yes | One-line summary |
| `url` | string | yes | `https://github.com/...`, `file://...`, or git URL |
| `kind` | string | no | `template` \| `addon` (informational) |
| `tags` | string[] | no | Discovery tags (`web`, `cli`, `ci`, …) |

## Example

See `fixtures/catalog/templates.json`.

## Resolution

CLI loads catalog from `CVA_CATALOG_URL` / `--catalog-url` / `--catalog-path`, then maps slug → `url` before git/file fetch (`docs/CATALOG.md`).
