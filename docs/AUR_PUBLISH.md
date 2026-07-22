# AUR publish tracking

Secondary channel: [`Create-Vlang-App/aur-package`](https://github.com/Create-Vlang-App/aur-package) mirrors the AUR package [`create-vlang-app`](https://aur.archlinux.org/packages/create-vlang-app).

## Automation

[`publish-aur.yml`](../.github/workflows/publish-aur.yml) runs after **Release** succeeds (or via manual dispatch):

1. Downloads the GitHub Release source tarball `create-vlang-app@X.Y.Z`
2. Updates `PKGBUILD` version + `sha256sums` in the aur-package mirror
3. Publishes to `aur.archlinux.org` via SSH
4. Verifies AUR RPC version and syncs the GitHub mirror

## Manual dispatch

```bash
gh workflow run "Publish to AUR" --repo Create-Vlang-App/create-vlang-app -f version=0.0.1
```

Secrets live in the GitHub **`release`** environment — see [DISTRIBUTION_SETUP.md](DISTRIBUTION_SETUP.md).
