# CLI flags

| Flag | Description |
|------|-------------|
| `--template` / `-t` | Template slug or URL |
| `--addons` / `-a` | Comma-separated addons |
| `--fixture` | Use `fixtures/catalog/templates.json` |
| `--fixture-dir` | Custom fixture catalog directory |
| `--catalog-path` / `--catalog-url` | Catalog overrides |
| `--json` | JSON for cache subcommands |
| `--add-completion` | Emit bash/zsh/fish completion |
| `--set key=value` | Write overlay into `cva.config.json` |
| `--no-interactive` / `--force` / `--no-install` | CI-friendly defaults |
| `cache dir\|list\|clean\|verify\|outdated\|update\|doctor` | Cache management |

## Examples

Install via `install.sh`:

```bash
curl -LsSf https://create-awesome-vlang-app.vercel.app/install.sh | sh
```

Headless scaffold with pinned template and addons:

```bash
create-vlang-app my-app \
  --template web-server \
  --addons github-setup,docker \
  --no-interactive
```

The `create-awesome-vlang-app` alias works identically:

```bash
create-awesome-vlang-app my-app -t web-server -a github-setup --no-interactive
```

Local catalog override (offline development):

```bash
create-vlang-app my-app --catalog-path ./cva-templates/templates.json
# or
create-vlang-app my-app --catalog-url file:///path/to/templates.json
```
