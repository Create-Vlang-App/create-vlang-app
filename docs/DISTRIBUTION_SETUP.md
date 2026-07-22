# Distribution Channels — One-Time Setup

`create-vlang-app` publishes on release tags (`create-vlang-app@X.Y.Z`):

| Channel | Workflow | Secret(s) |
|---------|----------|-----------|
| **VPM** | Manual registry + `v install` | (none — public GitHub) |
| **GitHub Releases** | `publish.yml` (Release) | `GITHUB_TOKEN` (default) |
| **Docker** | `publish-docker.yml` (after Release) | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` |
| **AUR** | `publish-aur.yml` (after Release) | `AUR_SSH_PRIVATE_KEY`, `AUR_REPO_TOKEN` |
| **Homebrew** | `notify-homebrew.yml` → `homebrew-tap` | `HOMEBREW_TAP_TOKEN` |

Configure secrets under **Settings → Environments → `release` → Environment secrets**
(not repository Action secrets). Docker, AUR, and Homebrew jobs use `environment: release`.

Secondary channels run via `workflow_run` **after** Release succeeds so they do not race
the tag push. Each consumer polls GitHub Release tarballs/assets with retries.

See also:

- [VPM_PUBLISH.md](VPM_PUBLISH.md) — primary install path
- [AUR_PUBLISH.md](AUR_PUBLISH.md) — AUR automation details

## VPM (primary)

Register modules at [vpm.vlang.io/new](https://vpm.vlang.io/new):

| Install name | Module path |
|--------------|-------------|
| `create-vlang-app` | `modules/create_vlang_app` |
| `create-vlang-app-core` | `modules/create_vlang_app_core` |

Verify:

```bash
v install create-vlang-app
create-vlang-app --version
```

## Cutting a release

1. Bump semver in all locations listed in [VPM_PUBLISH.md](VPM_PUBLISH.md)
2. Run `./scripts/check-version-sync.sh`
3. Merge to `main`
4. Tag and push:

```bash
git tag create-vlang-app@X.Y.Z
git push origin create-vlang-app@X.Y.Z
```

Then:

1. Confirm **Release** uploads binaries + `SHA256SUMS`
2. Confirm **Publish Docker image**, **Publish to AUR**, and **Notify Homebrew tap** complete
3. Run distribution smoke: `gh workflow run "Distribution smoke tests"`

## Docker Hub

Image: [`ulisesjeremias/create-vlang-app`](https://hub.docker.com/r/ulisesjeremias/create-vlang-app)

Secrets (reuse CNA/CPA Hub account if desired):

- `DOCKERHUB_USERNAME` — e.g. `ulisesjeremias`
- `DOCKERHUB_TOKEN` — Hub access token with write scope

Verify:

```bash
gh workflow run "Publish Docker image" --repo Create-Vlang-App/create-vlang-app -f version=0.0.1
docker run --rm ulisesjeremias/create-vlang-app:0.0.1 --version
```

## AUR (`AUR_SSH_PRIVATE_KEY`, `AUR_REPO_TOKEN`)

**Prereqs**: AUR account for `create-vlang-app`, mirror [`Create-Vlang-App/aur-package`](https://github.com/Create-Vlang-App/aur-package).

### Bootstrap the AUR package (first release only)

```bash
ssh-keyscan -H aur.archlinux.org >> ~/.ssh/known_hosts

cd /tmp
rm -rf aur-bootstrap
git clone git@github.com:Create-Vlang-App/aur-package.git aur-bootstrap
cd aur-bootstrap
git remote add aur ssh://aur@aur.archlinux.org/create-vlang-app.git
git push aur main:master
```

If AUR rejects the push, create the package via [aur.archlinux.org/submit](https://aur.archlinux.org/submit) first.

### Generate / register the AUR SSH key

```bash
ssh-keygen -t ed25519 -C "aur-publish-cva" -f ~/.ssh/aur_publish_cva -N ""
cat ~/.ssh/aur_publish_cva.pub
```

Paste the public key at [AUR → My Account → SSH Public Key](https://aur.archlinux.org/account).
Store the **private** key as `AUR_SSH_PRIVATE_KEY` in the `release` environment.

### Generate `AUR_REPO_TOKEN`

Fine-grained PAT with **Contents: Read and write** on `Create-Vlang-App/aur-package` only.

## Homebrew (`HOMEBREW_TAP_TOKEN`)

**Prereqs**: [`Create-Vlang-App/homebrew-tap`](https://github.com/Create-Vlang-App/homebrew-tap) with
`Formula/create-vlang-app.rb` and `update-formula.yml`.

Fine-grained PAT with:

- Repository: `Create-Vlang-App/homebrew-tap`
- **Contents**: Read and write
- **Actions**: Read and write (for `repository_dispatch`)

Store as `HOMEBREW_TAP_TOKEN` in the `release` environment.

Install:

```bash
brew tap Create-Vlang-App/tap
brew install create-vlang-app
```

## Verification

```bash
# Homebrew notify
gh workflow run "Notify Homebrew tap" --repo Create-Vlang-App/create-vlang-app -f version=0.0.1

# AUR publish
gh workflow run "Publish to AUR" --repo Create-Vlang-App/create-vlang-app -f version=0.0.1

# Local smoke (partial)
./scripts/smoke-distribution.sh 0.0.1

# End-user checks
v install create-vlang-app && create-vlang-app --version
brew install create-vlang-app && create-vlang-app --version
yay -S create-vlang-app && create-vlang-app --version
docker run --rm ulisesjeremias/create-vlang-app:latest --help
```

## Scheduled distribution smoke

`Distribution smoke tests` runs daily, after Release, and via manual dispatch:

```bash
gh workflow run "Distribution smoke tests" --repo Create-Vlang-App/create-vlang-app
gh run list --workflow smoke-distribution.yml --repo Create-Vlang-App/create-vlang-app --limit 5
```

Channel version mismatches emit warnings when downstream packages lag the latest GitHub
Release; install/help failures must stay red.

## After secrets are in place

Every subsequent release only requires tagging `create-vlang-app@X.Y.Z`.
**Release** publishes binaries; Docker, AUR, and Homebrew notify follow automatically.
