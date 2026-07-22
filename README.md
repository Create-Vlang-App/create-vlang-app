<div align="center">

# Create Vlang App

**V-native scaffolding CLI — compose templates and extensions into production-ready V projects.**

One command. Any V stack.

[![CI Tests](https://github.com/Create-Vlang-App/create-vlang-app/actions/workflows/test.yml/badge.svg)](https://github.com/Create-Vlang-App/create-vlang-app/actions/workflows/test.yml)
[![Lint](https://github.com/Create-Vlang-App/create-vlang-app/actions/workflows/lint.yml/badge.svg)](https://github.com/Create-Vlang-App/create-vlang-app/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/Create-Vlang-App/create-vlang-app?filter=create-vlang-app%40*&style=flat-square&label=Release)](https://github.com/Create-Vlang-App/create-vlang-app/releases/tag/create-vlang-app%400.1.0)
[![V](https://img.shields.io/badge/V-0.5.2-4B6EAF?style=flat-square)](https://vlang.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

[Templates](https://github.com/Create-Vlang-App/cva-templates) · [Website](https://github.com/Create-Vlang-App/website) · [Contributing](CONTRIBUTING.md) · [Releases](https://github.com/Create-Vlang-App/create-vlang-app/releases)

</div>

---

## Quick start

### From Release (recommended)

Download the linux amd64 binary from [`create-vlang-app@0.1.0`](https://github.com/Create-Vlang-App/create-vlang-app/releases/tag/create-vlang-app%400.1.0):

```bash
curl -fsSL -o create-vlang-app \
  "https://github.com/Create-Vlang-App/create-vlang-app/releases/download/create-vlang-app%400.1.0/create-vlang-app-linux-x86_64"
chmod +x create-vlang-app
sudo mv create-vlang-app /usr/local/bin/

create-vlang-app my-app --template web-server --addons github-setup
```

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
| [website](https://github.com/Create-Vlang-App/website) | Docs / catalog UI |
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
