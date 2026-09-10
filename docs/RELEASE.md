# Release

Cut a tag:

```bash
git tag create-vlang-app@0.2.0
git push origin create-vlang-app@0.2.0
```

`.github/workflows/publish.yml` builds binaries and creates a GitHub Release.

## Asset matrix (0.2.x)

| Asset | Status |
|-------|--------|
| `create-vlang-app-linux-x86_64` | **Required** — published on every `create-vlang-app@*` tag |
| `create-vlang-app-linux-aarch64` | Shipped in 0.2.0+; `continue-on-error` when cross-build unavailable |
| `create-vlang-app-darwin-aarch64` | Shipped in 0.2.0+; `continue-on-error` |
| `create-vlang-app-darwin-x86_64` | Optional — pending the `macos-15-intel` runner fix in #239; expected in 0.2.1+ |
| `create-vlang-app-windows-x86_64.exe` | Shipped in 0.2.0+; `continue-on-error` |
| `SHA256SUMS` | **Required** — covers all uploaded assets for installer verification |

Primary install for CI and bank L1–L3: **linux amd64 Release binary**.
See `.github/workflows/publish.yml` matrix `optional` flags.

## curl|sh installer

User-facing installer: [`scripts/install.sh`](../scripts/install.sh) (mirrored at
`https://create-awesome-vlang-app.vercel.app/install.sh`).

Every `create-vlang-app@*` Release **must** publish:

1. At least `create-vlang-app-linux-x86_64` (required)
2. `SHA256SUMS` covering uploaded assets (required for installer verification)

Optional platform assets enable the same oneliner on those hosts when present.
