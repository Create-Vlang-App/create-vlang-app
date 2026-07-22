# create-vlang-app

[![CI](https://img.shields.io/badge/CI-pending-lightgrey?style=flat-square)](https://github.com/Create-Vlang-App/create-vlang-app/actions)
[![V](https://img.shields.io/badge/V-0.5%2B-4B6EAF?style=flat-square)](https://vlang.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![VPM](https://img.shields.io/badge/vpm-create--vlang--app-blue?style=flat-square)](https://github.com/Create-Vlang-App/create-vlang-app)

V-native scaffolding CLI for the [V programming language](https://vlang.io) — parity with [Create Node App](https://github.com/Create-Node-App/create-node-app) and [Create Python App](https://github.com/Create-Python-App/create-python-app).

```bash
# coming soon
v install create-vlang-app
create-vlang-app my-project
```

## Status

Bootstrapping. Roadmap: [issue #1](https://github.com/Create-Vlang-App/create-vlang-app/issues/1).

## Layout

See [docs/adr/0001-module-layout.md](docs/adr/0001-module-layout.md).

```text
modules/create_vlang_app_core   # scaffolding engine
modules/create_vlang_app        # CLI binary
```

## Toolchain

Pinned via [`.v-version`](.v-version). CI should use [`vlang/setup-v`](https://github.com/vlang/setup-v) with `version-file: .v-version`.

## Development

```bash
make test
make fmt
make vet
make build
```

## License

[MIT](LICENSE)

## Topics

GitHub topics: `vlang`, `scaffolding`, `cli`, `vpm`, `hacktoberfest`.

## Related

- [cva-templates](https://github.com/Create-Vlang-App/cva-templates)
- [website](https://github.com/Create-Vlang-App/website)
