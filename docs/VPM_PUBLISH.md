# VPM publish

## Goal

`v install create-vlang-app` after GitHub Release `create-vlang-app@X.Y.Z`.

## Current status (0.1.0)

- **Primary install path:** GitHub Release binary (`create-vlang-app-linux-x86_64`).
- **VPM registration:** may require interactive maintainer steps on [vlang/vpm](https://github.com/vlang/vpm). Until registered, document Release as the supported CI/install channel.

## Steps

1. Ensure `v.mod` name/version match the release.
2. Tag `create-vlang-app@X.Y.Z` and confirm Release assets exist.
3. Publish to VPM per upstream docs (account approval may block automation).
4. Verify: `v install create-vlang-app` then `create-vlang-app --version`.

## Blockers

If VPM registration is blocked on interactive approval, keep Release binaries as the interim primary install for CI (`cva-templates` `scripts/ci/install-cva-cli.sh`).
