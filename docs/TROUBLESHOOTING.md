# Troubleshooting

## `import create_vlang_app_core` fails locally

Run via `make build` / `make test` so `.vmodules` is linked. See `Makefile` `ensure-vmodules`.

## Wrong V version

Check `.v-version` and `v version`. Use `vlang/setup-v` with `version-file` in CI.

## Cache / offline scaffolding

Reserved for `CVA_CACHE_DIR` / `--offline` once the engine lands (Epic 3–4).

## Distribution smoke failures

The scheduled `Distribution smoke tests` workflow exercises the Homebrew tap,
the AUR package, `v install`, the Docker image, and the `curl|sh` installer.
The failure modes below were first triaged in
[#192](https://github.com/Create-Vlang-App/create-vlang-app/issues/192).

### Homebrew: "Refusing to load formula from untrusted tap"

**Symptom:** `Refusing to load formula create-vlang-app/tap/create-vlang-app
from untrusted tap`.

**Cause:** Homebrew 4.6+ requires `brew trust` before loading formulas from a
third-party tap. macOS runners cycle into an untrusted-tap state.

**Workaround:**

```bash
brew tap Create-Vlang-App/tap
brew trust --formula create-vlang-app/tap/create-vlang-app
brew install create-vlang-app/tap/create-vlang-app
```

### AUR: "PKGBUILD does not exist"

**Symptom:** The AUR job fails with `PKGBUILD does not exist`.

**Cause:** The `aur.archlinux.org/create-vlang-app.git` clone fails when the
package is not yet published to the AUR RPC, and the fallback clone into
`/tmp/cva` silently fails because the directory already exists from the first
attempt (`git clone` into a non-empty dir fails quietly under `2>/dev/null`).

**Workaround:** Remove the stale clone before the fallback, and surface the
primary clone failure instead of silencing it:

```bash
rm -rf /tmp/cva
git clone https://aur.archlinux.org/create-vlang-app.git /tmp/cva
```

### V install: "create-vlang-app: command not found"

**Symptom:** The binary job fails with `create-vlang-app: command not found`
after `v install --git <repo>@main`.

**Cause:** `v install --git` installs VPM **modules** (here the workspace
module `create_vlang_app_workspace` per the root `v.mod`), not the CLI
executable — so nothing named `create-vlang-app` lands on `PATH`.

**Workaround:** Build the executable from the cloned source instead:

```bash
v -prod modules/create-vlang-app
```

### Docker Hub: "pull access denied"

**Symptom:** `pull access denied for ulisesjeremias/create-vlang-app,
repository does not exist or may require 'docker login'`.

**Cause:** The Docker image is not published (or CI credentials are not
configured) for the repository the workflow pulls from.

**Workaround:** Confirm the image exists and is public, or configure
`docker login` credentials in the workflow before pulling. See
[#192](https://github.com/Create-Vlang-App/create-vlang-app/issues/192) for
the current state of each channel.
