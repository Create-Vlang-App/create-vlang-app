# AUR publish tracking

Secondary channel: [`Create-Vlang-App/aur-package`](https://github.com/Create-Vlang-App/aur-package) mirrors:

| AUR package | Type |
|-------------|------|
| [`create-awesome-vlang-app`](https://aur.archlinux.org/packages/create-awesome-vlang-app) | Source (`makedepends=vlang`) |
| [`create-awesome-vlang-app-bin`](https://aur.archlinux.org/packages/create-awesome-vlang-app-bin) | Prebuilt `linux-x86_64` |

## Automation

[`publish-aur.yml`](../.github/workflows/publish-aur.yml) runs after **Release** succeeds (or via manual dispatch):

1. Downloads the GitHub Release source tarball / binary for `create-vlang-app@X.Y.Z`
2. Updates both PKGBUILDs (version + sha256) in the aur-package mirror
3. Publishes each package to `aur.archlinux.org` via SSH
4. Verifies AUR RPC and syncs the GitHub mirror

## Manual dispatch

```bash
gh workflow run "Publish to AUR" --repo Create-Vlang-App/create-vlang-app -f version=0.1.0
```

Secrets live in the GitHub **`release`** environment — see [DISTRIBUTION_SETUP.md](DISTRIBUTION_SETUP.md).
