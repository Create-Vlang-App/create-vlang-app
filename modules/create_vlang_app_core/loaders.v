module create_vlang_app_core

import os

pub fn copy_tree(src string, dst string) ! {
	if !os.is_dir(src) {
		return error(new_error(code_install, 'not a directory: ${src}').msg())
	}
	os.mkdir_all(dst) or {}
	entries := os.ls(src) or {
		return error(new_error(code_install, 'ls failed: ${src}').msg())
	}
	for name in entries {
		if name in ['.git', '.vmodules'] {
			continue
		}
		from := os.join_path(src, name)
		to := os.join_path(dst, name)
		if os.is_dir(from) {
			copy_tree(from, to)!
		} else {
			os.mkdir_all(os.dir(to)) or {}
			os.cp(from, to) or {
				return error(new_error(code_install, 'copy failed ${from}: ${err}').msg())
			}
		}
	}
}

pub fn merge_layers(layers []string, dest string) ! {
	os.mkdir_all(dest) or {}
	for layer in layers {
		src := ResolvedSource{
			kind: 'file'
			local_path: layer
		}
		root := get_template_dir_path(src, layer)
		copy_tree(root, dest)!
	}
}
