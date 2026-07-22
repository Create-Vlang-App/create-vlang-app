module create_vlang_app_core

import os

pub struct ScaffoldOptions {
pub:
	project_dir     string
	template_spec   string
	addon_specs     []string
	no_install      bool
	force           bool
	keep_on_failure bool
	skip_git        bool
	cache           CacheOptions
	catalog_path    string
	catalog_url     string
}

pub fn scaffold(opts ScaffoldOptions) ! {
	if opts.project_dir == '' {
		return error(new_error(code_install, 'project directory required').msg())
	}
	if os.exists(opts.project_dir) {
		entries := os.ls(opts.project_dir) or { []string{} }
		if entries.len > 0 && !opts.force {
			return error(new_error(code_non_empty_target, 'target not empty: ${opts.project_dir}').msg())
		}
	}
	os.mkdir_all(opts.project_dir) or {}

	mut cat := CatalogFile{}
	mut need_cat := spec_needs_catalog(opts.template_spec)
	for a in opts.addon_specs {
		if spec_needs_catalog(a) {
			need_cat = true
			break
		}
	}
	if need_cat || opts.catalog_path != '' {
		cat = load_catalog(opts.catalog_path, opts.catalog_url) or {
			cleanup_on_failure(opts)
			return err
		}
	}

	mut layers := []string{}
	template_url := resolve_user_spec(opts.template_spec, cat) or {
		cleanup_on_failure(opts)
		return err
	}
	template_src := resolve_source(template_url)
	template_root := ensure_cached(template_src, opts.cache) or {
		cleanup_on_failure(opts)
		return err
	}
	layers << get_template_dir_path(template_src, template_root)

	for addon in opts.addon_specs {
		aurl := resolve_user_spec(addon, cat) or {
			cleanup_on_failure(opts)
			return err
		}
		asrc := resolve_source(aurl)
		aroot := ensure_cached(asrc, opts.cache) or {
			cleanup_on_failure(opts)
			return err
		}
		layers << get_template_dir_path(asrc, aroot)
	}

	merge_layers(layers, opts.project_dir) or {
		cleanup_on_failure(opts)
		return err
	}

	// Merge v.mod files from layers if present
	mut vmods := []string{}
	for layer in layers {
		candidate := os.join_path(layer, 'v.mod')
		if os.exists(candidate) {
			vmods << candidate
		}
	}
	if vmods.len > 0 {
		merge_vmod_files(vmods, os.join_path(opts.project_dir, 'v.mod')) or {}
	}

	cfg_path := os.join_path(opts.project_dir, 'cva.config.json')
	if os.exists(cfg_path) {
		load_cva_config(cfg_path) or {}
	}

	if !opts.no_install {
		run_v_install(opts.project_dir) or {
			cleanup_on_failure(opts)
			return err
		}
	}

	if !opts.skip_git && os.getenv('CVA_SKIP_GIT') != '1' {
		init_git(opts.project_dir)
	}
}

fn cleanup_on_failure(opts ScaffoldOptions) {
	if opts.keep_on_failure {
		return
	}
	os.rmdir_all(opts.project_dir) or {}
}

fn run_v_install(dir string) ! {
	res := os.execute('v -C "${dir}" install')
	// `v install` may no-op without v.mod deps; ignore soft failures when no network
	if res.exit_code != 0 && os.getenv('CVA_STRICT_VERSION') == '1' {
		return error(new_error(code_install, 'v install failed: ${res.output}').msg())
	}
}

fn init_git(dir string) {
	if os.is_dir(os.join_path(dir, '.git')) {
		return
	}
	os.execute('git -C "${dir}" init')
}
