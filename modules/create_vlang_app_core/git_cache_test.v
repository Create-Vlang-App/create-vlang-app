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
		kind:       'file'
		url:        'file://${dir}'
		local_path: dir
	}
	got := ensure_cached(src, default_cache_options()) or {
		assert false, err.msg()
		return
	}
	assert got == dir
}

fn cache_test_opts() CacheOptions {
	dir := os.join_path(os.temp_dir(), 'cva-cache-test')
	os.rmdir_all(dir) or {}
	return CacheOptions{
		cache_dir: dir
		refresh:   'manual'
		pin:       ''
	}
}

fn test_cache_key_differs_by_ref() {
	a := cache_key('https://github.com/a/b', 'main')
	b := cache_key('https://github.com/a/b', 'dev')
	assert a != b
	assert a.len == 16 && b.len == 16
}

fn test_ensure_cached_file_missing_path() {
	src := ResolvedSource{
		kind:       'file'
		url:        'file:///nonexistent-cva-path'
		local_path: '/nonexistent-cva-path'
	}
	if _ := ensure_cached(src, cache_test_opts()) {
		assert false, 'expected error for missing local path'
	} else {
		assert err.msg().contains('local path missing')
	}
}

fn test_ensure_cached_unresolved_slug() {
	src := ResolvedSource{
		kind: 'slug'
		url:  'minimal'
	}
	if _ := ensure_cached(src, cache_test_opts()) {
		assert false, 'expected error for unresolved slug'
	} else {
		assert err.msg().contains('slug not resolved')
	}
}

fn test_default_cache_options_refresh_env() {
	os.setenv('CVA_REFRESH', 'always', true)
	assert default_cache_options().refresh == 'always'
	os.unsetenv('CVA_REFRESH')
	assert default_cache_options().refresh == 'stale'
}

fn test_should_refresh_missing_and_fresh() {
	dir := os.join_path(os.temp_dir(), 'cva-refresh-test')
	os.rmdir_all(dir) or {}
	os.mkdir_all(os.join_path(dir, '.git')) or {}
	assert should_refresh(dir) == true
	os.write_file(os.join_path(dir, '.git', 'FETCH_HEAD'), 'x') or {}
	assert should_refresh(dir) == false
}

fn make_local_git_repo() string {
	dir := os.join_path(os.temp_dir(), 'cva-git-src')
	os.rmdir_all(dir) or {}
	os.mkdir_all(dir) or {}
	os.write_file(os.join_path(dir, 'f.txt'), 'hi\n') or {}
	os.execute('git -C "${dir}" init -q')
	os.execute('git -C "${dir}" config user.email t@t.t')
	os.execute('git -C "${dir}" config user.name t')
	os.execute('git -C "${dir}" add .')
	os.execute('git -C "${dir}" commit -qm init')
	os.execute('git -C "${dir}" branch -M main')
	return dir
}

fn test_ensure_cached_local_git_clone_reuse_and_recover() {
	if os.execute('git --version').exit_code != 0 {
		return
	}
	src_dir := make_local_git_repo()
	opts := cache_test_opts()
	src := ResolvedSource{
		kind: 'git'
		url:  src_dir
	}
	first := ensure_cached(src, opts) or {
		assert false, err.msg()
		return
	}
	assert os.exists(os.join_path(first, 'f.txt'))
	second := ensure_cached(src, opts) or {
		assert false, err.msg()
		return
	}
	assert second == first
	// corrupt metadata: drop .git, next call must re-clone
	os.rmdir_all(os.join_path(first, '.git')) or {}
	third := ensure_cached(src, opts) or {
		assert false, err.msg()
		return
	}
	assert third == first
	assert os.exists(os.join_path(third, 'f.txt'))
}

fn test_ensure_cached_missing_ref_errors() {
	if os.execute('git --version').exit_code != 0 {
		return
	}
	src_dir := make_local_git_repo()
	opts := cache_test_opts()
	src := ResolvedSource{
		kind: 'git'
		url:  src_dir
		ref:  'nope'
	}
	if _ := ensure_cached(src, opts) {
		assert false, 'expected error for missing ref'
	} else {
		assert err.msg().contains('nope')
	}
}
