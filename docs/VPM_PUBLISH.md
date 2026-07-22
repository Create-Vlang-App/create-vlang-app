# VPM publish path

Primary distribution for **create-vlang-app** is [VPM](https://vpm.vlang.io/) (`v install create-vlang-app`).

## Modules

| VPM / install name | Path | Role |
|--------------------|------|------|
| `create-vlang-app` | `modules/create_vlang_app` | CLI binary |
| `create-vlang-app-core` | `modules/create_vlang_app_core` | Scaffolding engine |

V module identifiers use underscores in `v.mod`; install names use hyphens (see [ADR 0001](adr/0001-module-layout.md)).

## One-time VPM registration

1. Ensure each module directory has an accurate `v.mod` (`name`, `version`, `repo_url`, `license`).
2. Push the repository to `Create-Vlang-App/create-vlang-app` on GitHub.
3. Register packages at [vpm.vlang.io/new](https://vpm.vlang.io/new) (GitHub login required):
   - **CLI:** GitHub URL pointing at `modules/create_vlang_app` (or monorepo root if VPM expects repo root — confirm listing matches `v install create-vlang-app` UX).
   - **Core:** register `create-vlang-app-core` similarly for consumers importing the engine.
4. Add topics `vlang` and `vlang-package` on GitHub for discoverability.

> VPM entries cannot be edited after submission — double-check names and URLs.

## Version alignment

Release tags use **`create-vlang-app@X.Y.Z`**. The semver must match:

- root `v.mod`
- `modules/create_vlang_app/v.mod`
- `modules/create_vlang_app_core/v.mod`
- `modules/create_vlang_app/main.v` (`app_version`)
- `modules/create_vlang_app_core/create_vlang_app_core.v` (`version` const)

Check locally:

```bash
./scripts/check-version-sync.sh
TAG=create-vlang-app@0.0.1 ./scripts/check-version-sync.sh
```

The Release workflow runs the same check before uploading assets.

## Cutting a release

1. Bump all version locations above and update `CHANGELOG.md` (when present).
2. Merge to `main`.
3. Tag and push:

```bash
git tag create-vlang-app@X.Y.Z
git push origin create-vlang-app@X.Y.Z
```

4. Confirm the **Release** workflow publishes GitHub Release binaries.
5. Verify install:

```bash
v install create-vlang-app
create-vlang-app --version
```

Secondary channels (Docker, AUR, Homebrew) are notified after Release succeeds — see [DISTRIBUTION_SETUP.md](DISTRIBUTION_SETUP.md).

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `v install` pulls stale sources | `v update create-vlang-app` or pin with `v install --git …@tag` |
| Version mismatch errors | Re-run `./scripts/check-version-sync.sh` before tagging |
| Module not found | Confirm VPM registration and public GitHub repo |
