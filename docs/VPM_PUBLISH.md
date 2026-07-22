# VPM publish

## Goal
`v install create-vlang-app` after `create-vlang-app@X.Y.Z` GitHub Release.

## Steps
1. Ensure `v.mod` name/version match the release.
2. Tag `create-vlang-app@0.1.0` and push.
3. Confirm GitHub Release assets exist.
4. Publish to VPM per https://github.com/vlang/vpm (manual account steps may be required).
5. Verify: `v install create-vlang-app` then `create-vlang-app --version`.

## Blockers
If VPM registration requires interactive maintainer approval, document the URL here and keep Release binaries as the interim primary install for CI.
