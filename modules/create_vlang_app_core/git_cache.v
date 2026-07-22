module create_vlang_app_core

import os
import time
import crypto.md5

pub struct CacheOptions {
pub:
	cache_dir string
	refresh   string // always | stale | manual
	pin       string
}

pub fn default_cache_options() CacheOptions {
	refresh := os.getenv('CVA_REFRESH')
	return CacheOptions{
		cache_dir: default_cache_dir()
		refresh: if refresh != '' { refresh } else { 'stale' }
		pin: ''
	}
}

fn cache_key(url string, ref_name string) string {
	raw := '${url}@${ref_name}'
	return md5.hexhash(raw)[..16]
}

// ensure_cached clones or refreshes a git source into the disk cache.
pub fn ensure_cached(source ResolvedSource, opts CacheOptions) !string {
	if source.kind == 'file' {
		if source.local_path == '' || !os.is_dir(source.local_path) {
			return error(new_error(code_git_cache, 'local path missing: ${source.local_path}').msg())
		}
		return source.local_path
	}
	if source.kind == 'slug' {
		return error(new_error(code_git_cache, 'slug not resolved to URL: ${source.url}').msg())
	}

	os.mkdir_all(opts.cache_dir) or {}
	ref_name := if opts.pin != '' {
		opts.pin
	} else if source.ref != '' {
		source.ref
	} else {
		'main'
	}
	dest := os.join_path(opts.cache_dir, 'git', cache_key(source.url, ref_name))

	if os.is_dir(os.join_path(dest, '.git')) {
		if opts.refresh == 'always' || (opts.refresh == 'stale' && should_refresh(dest)) {
			fetch_repo(dest, ref_name)!
		}
		return dest
	}

	os.mkdir_all(os.dir(dest)) or {}
	clone_repo(source.url, dest, ref_name)!
	return dest
}

fn should_refresh(dest string) bool {
	meta := os.join_path(dest, '.git', 'FETCH_HEAD')
	if !os.exists(meta) {
		return true
	}
	hours := os.getenv('CVA_REFRESH_AFTER_HOURS').int()
	max_h := if hours > 0 { hours } else { 24 }
	mtime := os.file_last_mod_unix(meta)
	age_sec := time.now().unix() - mtime
	return age_sec >= (max_h * 3600)
}

fn clone_repo(url string, dest string, ref_name string) ! {
	os.rmdir_all(dest) or {}
	res := os.execute('git clone --depth 1 --branch "${ref_name}" "${url}" "${dest}"')
	if res.exit_code != 0 {
		res2 := os.execute('git clone --depth 1 "${url}" "${dest}"')
		if res2.exit_code != 0 {
			return error(new_error(code_git_cache, 'git clone failed: ${res2.output}').msg())
		}
		if ref_name != '' {
			os.execute('git -C "${dest}" checkout "${ref_name}"')
		}
	}
}

fn fetch_repo(dest string, ref_name string) ! {
	res := os.execute('git -C "${dest}" fetch --depth 1 origin "${ref_name}"')
	if res.exit_code != 0 {
		return error(new_error(code_git_cache, 'git fetch failed: ${res.output}').msg())
	}
	os.execute('git -C "${dest}" checkout FETCH_HEAD')
}
