module create_vlang_app_core

import net.http
import os

pub fn check_latest_release(owner string, repo string) string {
	if os.getenv('CVA_OFFLINE') == '1' {
		return ''
	}
	url := 'https://api.github.com/repos/${owner}/${repo}/releases/latest'
	resp := http.get(url) or { return '' }
	if resp.status_code != 200 {
		return ''
	}
	idx := resp.body.index('"tag_name"') or { return '' }
	rest := resp.body[idx..]
	colon := rest.index(':') or { return '' }
	val := rest[colon + 1..].trim_space()
	if !val.starts_with('"') {
		return ''
	}
	end := val.index_after('"', 1) or { return '' }
	return val[1..end]
}

pub const v_install_docs = 'https://create-awesome-vlang-app.vercel.app/docs/installation'

// v_upstream tracks the V toolchain policy: CVA always builds and tests
// against the latest master of vlang/v — there is no pinned compiler.
pub const v_upstream = 'https://github.com/vlang/v/tree/master'

// parse_v_version extracts X.Y.Z from `v version` output (`V 0.5.2 7647ce1`).
pub fn parse_v_version(output string) !string {
	parts := output.trim_space().split(' ')
	if parts.len >= 2 && parts[0] == 'V' && parts[1].count('.') == 2 {
		return parts[1]
	}
	return error(new_error(code_v_toolchain,
		'unexpected `v version` output: ${output.trim_space()}').msg())
}

// detected_v_version returns the installed V toolchain version.
pub fn detected_v_version() !string {
	if !os.exists_in_system_path('v') {
		return error(new_error(code_v_toolchain,
			'V toolchain not found in PATH. Install the latest V (${v_upstream}): ${v_install_docs}').msg())
	}
	res := os.execute('v version')
	if res.exit_code != 0 {
		return error(new_error(code_v_toolchain,
			'could not run `v version`: ${res.output.trim_space()}. See ${v_install_docs}').msg())
	}
	return parse_v_version(res.output)
}

// verify_v_toolchain errors when no usable V toolchain is installed and
// returns the detected version otherwise. Any detected version is accepted:
// CVA tracks the latest V master, so the gate checks presence — never a pin.
pub fn verify_v_toolchain() !string {
	return detected_v_version()
}

pub fn warn_if_outdated(current string) {
	if os.getenv('CVA_OFFLINE') == '1' {
		return
	}
	latest := check_latest_release('Create-Vlang-App', 'create-vlang-app')
	if latest == '' || latest == current || latest.trim_string_left('v') == current {
		return
	}
	eprintln('A newer create-vlang-app may be available: ${latest} (current ${current})')
}
