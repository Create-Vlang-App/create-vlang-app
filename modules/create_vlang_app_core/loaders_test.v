module create_vlang_app_core

import os

fn test_copy_tree() {
	src := os.join_path(os.temp_dir(), 'cva-load-src')
	dst := os.join_path(os.temp_dir(), 'cva-load-dst')
	os.rmdir_all(src) or {}
	os.rmdir_all(dst) or {}
	os.mkdir_all(os.join_path(src, 'a')) or {}
	os.write_file(os.join_path(src, 'a', 'b.txt'), 'hi') or {}
	copy_tree(src, dst) or { panic(err) }
	assert os.read_file(os.join_path(dst, 'a', 'b.txt')) or { '' } == 'hi'
}
