<div align="center">

<img src="./assets/repo-hero.svg" alt="Create Vlang App hero banner" width="100%" />

# Create Vlang App

**V-native scaffolding CLI — compose templates and extensions into production-ready V projects.**

One command. Any V stack.

[![CI Tests](https://github.com/Create-Vlang-App/create-vlang-app/actions/workflows/test.yml/badge.svg)](https://github.com/Create-Vlang-App/create-vlang-app/actions/workflows/test.yml)
[![Lint](https://github.com/Create-Vlang-App/create-vlang-app/actions/workflows/lint.yml/badge.svg)](https://github.com/Create-Vlang-App/create-vlang-app/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/Create-Vlang-App/create-vlang-app?filter=create-vlang-app%40*&style=flat-square&label=Release)](https://github.com/Create-Vlang-App/create-vlang-app/releases/tag/create-vlang-app%400.1.0)
[![V](https://img.shields.io/badge/V-0.5.2-4B6EAF?style=flat-square)](https://vlang.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Website](https://img.shields.io/badge/site-create--awesome--vlang--app.vercel.app-8B5CF6?style=flat-square)](https://create-awesome-vlang-app.vercel.app)
[![AUR](https://img.shields.io/aur/version/create-vlang-app?style=flat-square&label=AUR&logo=archlinux)](https://aur.archlinux.org/packages/create-vlang-app)
[![Homebrew](https://img.shields.io/badge/homebrew-Create--Vlang--App%2Ftap-orange?style=flat-square&logo=homebrew)](https://github.com/Create-Vlang-App/homebrew-tap)
[![Discord](https://img.shields.io/discord/1527933660764831825?style=flat-square&label=Discord&logo=discord&logoColor=white)](https://discord.gg/bR5VyATgka)

[Official Site](https://create-awesome-vlang-app.vercel.app) · [Catalog](https://create-awesome-vlang-app.vercel.app/templates) · [Templates](https://github.com/Create-Vlang-App/cva-templates) · [Contributing](CONTRIBUTING.md) · [Releases](https://github.com/Create-Vlang-App/create-vlang-app/releases)

</div>

---

## Quick start

### Install (recommended)

```bash
curl -fsSL https://create-awesome-vlang-app.vercel.app/install.sh | sh
# or
wget -qO- https://create-awesome-vlang-app.vercel.app/install.sh | sh
```

Installs `create-vlang-app` and a `create-awesome-vlang-app` alias into `~/.local/bin`
(override with `CVA_INSTALL_DIR`). Pin a version with `CVA_VERSION=0.1.0`.

Then scaffold:

```bash
create-vlang-app my-app --template web-server --addons github-setup
# or
create-awesome-vlang-app my-app --template web-server --addons github-setup
```

Fallback (raw script from this repo):

```bash
curl -fsSL https://raw.githubusercontent.com/Create-Vlang-App/create-vlang-app/main/scripts/install.sh | sh
```

### Manual / pin a Release asset

Download a specific platform binary from [`create-vlang-app@0.1.0`](https://github.com/Create-Vlang-App/create-vlang-app/releases/tag/create-vlang-app%400.1.0):

```bash
curl -fsSL -o create-vlang-app \
  "https://github.com/Create-Vlang-App/create-vlang-app/releases/download/create-vlang-app%400.1.0/create-vlang-app-linux-x86_64"
chmod +x create-vlang-app
mv create-vlang-app ~/.local/bin/
```

Also available via [Homebrew](https://github.com/Create-Vlang-App/homebrew-tap) (`brew tap Create-Vlang-App/tap && brew install create-vlang-app`) and [AUR](https://aur.archlinux.org/packages/create-vlang-app).

### Build from source

Requires [V](https://vlang.io) (pinned in [`.v-version`](.v-version)):

```bash
git clone https://github.com/Create-Vlang-App/create-vlang-app.git
cd create-vlang-app
make build
./create-vlang-app --help
```

Headless / CI:

```bash
create-vlang-app my-api \
  --template web-server \
  --addons github-setup \
  --no-interactive --force
```

List catalog entries:

```bash
create-vlang-app --list-templates
create-vlang-app --list-addons
```

Browse the live catalog at **[create-awesome-vlang-app.vercel.app/templates](https://create-awesome-vlang-app.vercel.app/templates)**.

## What this repo contains

| Path | Purpose |
|------|---------|
| [`modules/create_vlang_app_core`](modules/create_vlang_app_core) | Scaffolding engine (catalog, fetch, merge, install) |
| [`modules/create_vlang_app`](modules/create_vlang_app) | CLI binary |
| [`docs/`](docs) | ADRs, distribution, VPM notes |

Template and extension **content** lives in [`cva-templates`](https://github.com/Create-Vlang-App/cva-templates). The CLI consumes:

```text
https://raw.githubusercontent.com/Create-Vlang-App/cva-templates/main/templates.json
```

Override with `--catalog-path` or a fork for local testing (`file://` supported).

## Ecosystem

| Repository | Role |
|------------|------|
| [create-vlang-app](https://github.com/Create-Vlang-App/create-vlang-app) (this repo) | CLI + core engine |
| [cva-templates](https://github.com/Create-Vlang-App/cva-templates) | Official templates and extensions |
| [website](https://github.com/Create-Vlang-App/website) | Docs / catalog UI → [live site](https://create-awesome-vlang-app.vercel.app) |
| [homebrew-tap](https://github.com/Create-Vlang-App/homebrew-tap) | Homebrew formula |
| [aur-package](https://github.com/Create-Vlang-App/aur-package) | AUR PKGBUILD mirror |

## Local development

```bash
make test
make fmt
make vet
make build
```

CI uses [`vlang/setup-v`](https://github.com/vlang/setup-v) with `version-file: .v-version`.

## License

[MIT](LICENSE)

## Contributors

<a href="https://github.com/Create-Vlang-App/create-vlang-app/contributors">
  <img src="https://contrib.rocks/image?repo=Create-Vlang-App/create-vlang-app" alt="contrib.rocks"/>
</a>
