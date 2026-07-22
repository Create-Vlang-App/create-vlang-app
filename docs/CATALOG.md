# Catalog and slug resolution

`create-vlang-app` resolves short template/addon **slugs** through a `templates.json` catalog.

## Default source

`https://raw.githubusercontent.com/Create-Vlang-App/cva-templates/main/templates.json`

Override with:

- `--catalog-url <url>`
- `--catalog-path <file>` (offline / CI fixtures)
- `CVA_CATALOG_URL`

## Listing

```bash
create-vlang-app --list-templates --catalog-path fixtures/catalog/templates.json
create-vlang-app --list-addons --catalog-path fixtures/catalog/templates.json
```

## Scaffold with slugs

```bash
create-vlang-app ./out \
  --template minimal \
  --addons github-setup \
  --catalog-path fixtures/catalog/templates.json \
  --no-interactive --force --no-install
```

Full URLs (`file://`, `https://github.com/...`, git SSH) bypass catalog lookup.
