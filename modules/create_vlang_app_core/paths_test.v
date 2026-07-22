module create_vlang_app_core

fn test_resolve_slug() {
	s := resolve_source('web-server')
	assert s.kind == 'slug'
	assert s.url == 'web-server'
}

fn test_resolve_file_url() {
	s := resolve_source('file:///tmp/fixture-template')
	assert s.kind == 'file'
	assert s.local_path == '/tmp/fixture-template'
}

fn test_resolve_github_with_ref() {
	s := resolve_source('https://github.com/Create-Vlang-App/cva-templates?ref=main')
	assert s.kind == 'github'
	assert s.ref == 'main'
}

fn test_default_cache_dir_contains_cva() {
	d := default_cache_dir()
	assert d.contains('.cache')
	assert d.contains('cva')
}

fn test_resolve_ssh_git_url() {
	s := resolve_source('git@github.com:Create-Vlang-App/cva-templates.git')
	assert s.kind == 'git' || s.kind == 'github'
	assert s.url.contains('git@github.com')
}
