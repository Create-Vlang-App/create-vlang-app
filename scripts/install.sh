#!/usr/bin/env sh
# install.sh — install create-vlang-app from GitHub Releases (curl|sh / wget|sh).
#
# Usage:
#   curl -fsSL https://create-awesome-vlang-app.vercel.app/install.sh | sh
#   wget -qO- https://create-awesome-vlang-app.vercel.app/install.sh | sh
#
# Env:
#   CVA_VERSION=0.1.0              # semver without tag prefix
#   CVA_RELEASE_TAG=create-vlang-app@0.1.0
#   CVA_INSTALL_DIR=$HOME/.local/bin
#   CVA_DRY_RUN=1                  # print actions only
#   CVA_NO_MODIFY_PATH=1           # reserved; this script never edits shell rc files
#   CVA_REPO=Create-Vlang-App/create-vlang-app
#
# Installs create-vlang-app and a create-awesome-vlang-app symlink.
set -eu

REPO="${CVA_REPO:-Create-Vlang-App/create-vlang-app}"
BIN_NAME="create-vlang-app"
ALIAS_NAME="create-awesome-vlang-app"
INSTALL_DIR="${CVA_INSTALL_DIR:-${HOME}/.local/bin}"
DRY_RUN="${CVA_DRY_RUN:-0}"
GITHUB_API="${GITHUB_API:-https://api.github.com}"
GITHUB_DOWNLOAD="${GITHUB_DOWNLOAD:-https://github.com}"

info() { printf '%s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

need_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

download() {
	# download <url> <dest>
	_url=$1
	_dest=$2
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL "$_url" -o "$_dest"
	elif command -v wget >/dev/null 2>&1; then
		wget -qO "$_dest" "$_url"
	else
		die "need curl or wget"
	fi
}

http_get() {
	# http_get <url> → stdout
	_url=$1
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL "$_url"
	elif command -v wget >/dev/null 2>&1; then
		wget -qO- "$_url"
	else
		die "need curl or wget"
	fi
}

detect_platform() {
	_os=$(uname -s | tr '[:upper:]' '[:lower:]')
	_arch=$(uname -m)
	case "$_os" in
	linux) _os=linux ;;
	darwin) _os=darwin ;;
	*)
		die "unsupported OS '$_os'. See https://github.com/${REPO}/releases or use Homebrew/AUR/WSL."
		;;
	esac
	case "$_arch" in
	x86_64 | amd64) _arch=x86_64 ;;
	aarch64 | arm64) _arch=aarch64 ;;
	*)
		die "unsupported architecture '$_arch'. See https://github.com/${REPO}/releases"
		;;
	esac
	printf '%s-%s\n' "$_os" "$_arch"
}

resolve_tag() {
	if [ -n "${CVA_RELEASE_TAG:-}" ]; then
		printf '%s\n' "$CVA_RELEASE_TAG"
		return
	fi
	if [ -n "${CVA_VERSION:-}" ]; then
		printf 'create-vlang-app@%s\n' "$CVA_VERSION"
		return
	fi
	# Prefer releases/latest when it is a CVA tag; otherwise scan recent releases.
	_latest_json=$(http_get "${GITHUB_API}/repos/${REPO}/releases/latest" 2>/dev/null || true)
	if [ -n "$_latest_json" ]; then
		_tag=$(printf '%s' "$_latest_json" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)
		case "$_tag" in
		create-vlang-app@*)
			printf '%s\n' "$_tag"
			return
			;;
		esac
	fi
	_list_json=$(http_get "${GITHUB_API}/repos/${REPO}/releases?per_page=30")
	_tag=$(printf '%s' "$_list_json" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\(create-vlang-app@[^\"]*\)".*/\1/p' | head -n1)
	[ -n "$_tag" ] || die "could not resolve a create-vlang-app@* release tag"
	printf '%s\n' "$_tag"
}

verify_sha256() {
	# verify_sha256 <file> <asset_basename> <sha256sums_file>
	_file=$1
	_asset=$2
	_sums=$3
	_expected=$(grep -E "[[:space:]]${_asset}\$" "$_sums" | awk '{print $1}' | head -n1)
	[ -n "$_expected" ] || die "SHA256SUMS has no entry for ${_asset}"

	if command -v sha256sum >/dev/null 2>&1; then
		_actual=$(sha256sum "$_file" | awk '{print $1}')
	elif command -v shasum >/dev/null 2>&1; then
		_actual=$(shasum -a 256 "$_file" | awk '{print $1}')
	else
		info "warning: sha256sum/shasum not found — skipping checksum verification"
		return 0
	fi
	[ "$_actual" = "$_expected" ] || die "checksum mismatch for ${_asset} (expected ${_expected}, got ${_actual})"
	info "checksum ok (${_asset})"
}

path_hint() {
	case ":${PATH}:" in
	*":${INSTALL_DIR}:"*) return 0 ;;
	esac
	info ""
	info "${INSTALL_DIR} is not on your PATH. Add it, for example:"
	info "  export PATH=\"${INSTALL_DIR}:\$PATH\""
	info "Or append that line to your shell profile (~/.bashrc / ~/.zshrc)."
}

main() {
	need_cmd uname
	need_cmd mktemp
	need_cmd mkdir
	need_cmd chmod
	need_cmd mv
	need_cmd ln
	need_cmd grep
	need_cmd awk
	need_cmd sed
	need_cmd head
	need_cmd tr

	_platform=$(detect_platform)
	_asset="${BIN_NAME}-${_platform}"
	_tag=$(resolve_tag)
	# URL-encode @ as %40 for download paths
	_tag_enc=$(printf '%s' "$_tag" | sed 's/@/%40/g')
	_base="${GITHUB_DOWNLOAD}/${REPO}/releases/download/${_tag_enc}"
	_bin_url="${_base}/${_asset}"
	_sums_url="${_base}/SHA256SUMS"

	info "Create Vlang App installer"
	info "  tag:      ${_tag}"
	info "  asset:    ${_asset}"
	info "  install:  ${INSTALL_DIR}/${BIN_NAME}"
	info "  alias:    ${INSTALL_DIR}/${ALIAS_NAME}"

	if [ "$DRY_RUN" = "1" ]; then
		info "dry-run: would download ${_bin_url}"
		info "dry-run: would verify ${_sums_url}"
		exit 0
	fi

	_tmpdir=$(mktemp -d)
	# shellcheck disable=SC2064
	trap 'rm -rf "$_tmpdir"' EXIT INT TERM

	info "downloading ${_asset}…"
	if ! download "$_bin_url" "${_tmpdir}/${_asset}"; then
		die "failed to download ${_bin_url}. Platform may be optional for this release — see https://github.com/${REPO}/releases"
	fi

	info "downloading SHA256SUMS…"
	if download "$_sums_url" "${_tmpdir}/SHA256SUMS"; then
		verify_sha256 "${_tmpdir}/${_asset}" "$_asset" "${_tmpdir}/SHA256SUMS"
	else
		info "warning: SHA256SUMS not available — skipping checksum verification"
	fi

	mkdir -p "$INSTALL_DIR"
	chmod +x "${_tmpdir}/${_asset}"
	mv "${_tmpdir}/${_asset}" "${INSTALL_DIR}/${BIN_NAME}"
	ln -sfn "${BIN_NAME}" "${INSTALL_DIR}/${ALIAS_NAME}"

	info ""
	info "installed ${BIN_NAME} → ${INSTALL_DIR}/${BIN_NAME}"
	info "alias     ${ALIAS_NAME} → ${INSTALL_DIR}/${ALIAS_NAME}"

	if "${INSTALL_DIR}/${BIN_NAME}" --version >/dev/null 2>&1; then
		info "version:  $("${INSTALL_DIR}/${BIN_NAME}" --version)"
	fi
	if "${INSTALL_DIR}/${ALIAS_NAME}" --version >/dev/null 2>&1; then
		info "alias ok: $("${INSTALL_DIR}/${ALIAS_NAME}" --version)"
	fi

	path_hint
	info ""
	info "Scaffold:"
	info "  ${BIN_NAME} my-app --template web-server --addons github-setup"
	info "  # or: ${ALIAS_NAME} my-app --template web-server"
}

main "$@"
