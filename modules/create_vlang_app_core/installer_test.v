module create_vlang_app_core

import os

fn test_scaffold_from_file() {
	src := os.join_path(os.temp_dir(), 'cva-scaffold-src')
	dst := os.join_path(os.temp_dir(), 'cva-scaffold-dst')
	os.rmdir_all(src) or {}
	os.rmdir_all(dst) or {}
	os.mkdir_all(src) or {}
	os.write_file(os.join_path(src, 'hello.txt'), 'world') or {}
	os.write_file(os.join_path(src, 'v.mod'), "Module {\n\tname: 'demo'\n\tversion: '0.0.1'\n\tdependencies: []\n}\n") or {}
	opts := ScaffoldOptions{
		project_dir: dst
		template_spec: 'file://${src}'
		no_install: true
		skip_git: true
		cache: default_cache_options()
	}
	scaffold(opts) or { panic(err) }
	assert os.read_file(os.join_path(dst, 'hello.txt')) or { '' } == 'world'
	assert os.exists(os.join_path(dst, 'v.mod'))
}
