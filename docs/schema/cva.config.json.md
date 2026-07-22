# `cva.config.json` vs CNA/CPA

| Concept | CNA | CPA | CVA |
|---------|-----|-----|-----|
| Config file | `cna.config.json` | `cpa.config.json` | `cva.config.json` |
| Env prefix | `CNA_*` | `CPA_*` | `CVA_*` |
| Package manager | npm/pnpm | uv/pip | VPM / `v.mod` |
| Templating | often copy + light subst | copy-first | **copy-first** (ADR); heavy templating optional later |

## Minimal schema (current)

```json
{
  "name": "my-app",
  "version": "0.0.1",
  "template": "web-server",
  "addons": ["github-setup"]
}
```

Core parser: `modules/create_vlang_app_core/config.v` — unknown fields ignored; missing file is OK.
