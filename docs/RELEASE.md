# Release

Cut a tag:

```bash
git tag create-vlang-app@0.1.0
git push origin create-vlang-app@0.1.0
```

`.github/workflows/publish.yml` builds binaries and creates a GitHub Release.

## Guaranteed vs optional assets (0.1.x)

| Asset | Status |
|-------|--------|
| `create-vlang-app-linux-x86_64` | **Required** — published on every `create-vlang-app@*` tag |
| `create-vlang-app-linux-aarch64` | Optional (`continue-on-error`) — uploaded when cross-build succeeds |
| `create-vlang-app-darwin-*` | Optional — macOS runners may fail V bootstrap; retry via workflow_dispatch |
| `create-vlang-app-windows-x86_64` | Optional — native Windows runner; may fail V bootstrap |

Primary install for CI and bank L1–L3: **linux amd64 Release binary**.
See `.github/workflows/publish.yml` matrix `optional` flags.
