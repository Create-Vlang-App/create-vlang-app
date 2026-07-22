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
