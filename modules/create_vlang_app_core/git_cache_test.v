module create_vlang_app_core

import os

fn test_cache_key_stable() {
	a := cache_key('https://github.com/a/b', 'main')
	b := cache_key('https://github.com/a/b', 'main')
	assert a == b
	assert a.len == 16
}

fn test_ensure_cached_file() {
	dir := os.join_path(os.temp_dir(), 'cva-file-src')
	os.mkdir_all(dir) or {}
	os.write_file(os.join_path(dir, 'ok.txt'), 'x') or {}
	src := ResolvedSource{
		kind: 'file'
		url: 'file://${dir}'
		local_path: dir
	}
	got := ensure_cached(src, default_cache_options()) or {
		assert false, err.msg()
		return
	}
	assert got == dir
}
