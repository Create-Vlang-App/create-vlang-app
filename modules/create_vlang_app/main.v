module main

import os
import flag
import create_vlang_app_core as core

const app_version = '0.0.1'

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('create-vlang-app')
	fp.version(app_version)
	fp.description('Scaffold V projects from templates and extensions')
	fp.skip_executable()

	show_info := fp.bool('info', `i`, false, 'print environment info')
	verbose := fp.bool('verbose', `v`, false, 'verbose output')
	template_spec := fp.string('template', `t`, '', 'template URL, file://, or slug')
	addons_flag := fp.string('addons', `a`, '', 'comma-separated addon slugs or URLs')
	_ := fp.string('extend', 0, '', 'alias for --addons (single value; prefer --addons)')
	_ := fp.string('set', 0, '', 'set key=value (reserved)')
	force := fp.bool('force', `f`, false, 'allow non-empty target directory')
	no_install := fp.bool('no-install', 0, false, 'skip v install')
	interactive := fp.bool('interactive', 0, true, 'interactive prompts')
	no_interactive := fp.bool('no-interactive', 0, false, 'disable interactive prompts')
	list_templates := fp.bool('list-templates', 0, false, 'list templates from catalog')
	list_addons := fp.bool('list-addons', 0, false, 'list addons from catalog')
	offline := fp.bool('offline', 0, false, 'offline mode')
	no_cache := fp.bool('no-cache', 0, false, 'bypass catalog cache')
	cache_dir := fp.string('cache-dir', 0, '', 'override CVA_CACHE_DIR')
	pin := fp.string('pin', 0, '', 'pin git ref')
	refresh := fp.string('refresh', 0, '', 'always|stale|manual')
	strict_version := fp.bool('strict-version', 0, false, 'strict version checks')
	keep_on_failure := fp.bool('keep-on-failure', 0, false, 'keep project dir on failure')
	catalog_url := fp.string('catalog-url', 0, '', 'override templates.json URL')
	catalog_path := fp.string('catalog-path', 0, '', 'local templates.json path')

	additional := fp.finalize() or {
		eprintln(err)
		exit(2)
	}

	if show_info {
		println(core.env_info())
		return
	}

	apply_env(offline, no_cache, cache_dir, refresh, strict_version)

	if list_templates || list_addons {
		cat := core.load_catalog(catalog_path, catalog_url) or {
			eprintln(err)
			exit(1)
		}
		if list_templates {
			println(core.format_catalog_list('Templates', core.list_template_names(cat)))
		}
		if list_addons {
			println(core.format_catalog_list('Addons', core.list_addon_names(cat)))
		}
		return
	}

	// cache subcommand
	if additional.len > 0 && additional[0] == 'cache' {
		run_cache_cmd(additional[1..])
		return
	}

	project := if additional.len > 0 { additional[0] } else { '' }
	use_interactive := interactive && !no_interactive

	mut addons := []string{}
	if addons_flag != '' {
		for part in addons_flag.split(',') {
			s := part.trim_space()
			if s != '' {
				addons << s
			}
		}
	}
	// also collect repeated --addons / --extend from raw args
	for i, a in os.args {
		if a == '--addons' || a == '--extend' {
			if i + 1 < os.args.len {
				val := os.args[i + 1]
				if !addons.contains(val) {
					for part in val.split(',') {
						s := part.trim_space()
						if s != '' && !addons.contains(s) {
							addons << s
						}
					}
				}
			}
		}
	}
	_ = verbose

	mut project_dir := project
	mut tmpl := template_spec
	if use_interactive {
		if project_dir == '' {
			project_dir = os.input('Project directory: ').trim_space()
		}
		if tmpl == '' {
			tmpl = os.input('Template (URL|file://|slug): ').trim_space()
		}
	}
	if project_dir == '' || tmpl == '' {
		eprintln('usage: create-vlang-app <project-directory> --template <spec> [--addons <spec>] [--no-interactive]')
		exit(2)
	}

	core.warn_if_outdated(app_version)

	mut cache := core.default_cache_options()
	if cache_dir != '' {
		cache = core.CacheOptions{
			cache_dir: cache_dir
			refresh: if refresh != '' { refresh } else { cache.refresh }
			pin: pin
		}
	} else if pin != '' || refresh != '' {
		cache = core.CacheOptions{
			cache_dir: cache.cache_dir
			refresh: if refresh != '' { refresh } else { cache.refresh }
			pin: pin
		}
	}

	opts := core.ScaffoldOptions{
		project_dir: project_dir
		template_spec: tmpl
		addon_specs: addons
		no_install: no_install
		force: force
		keep_on_failure: keep_on_failure
		skip_git: os.getenv('CVA_SKIP_GIT') == '1'
		cache: cache
		catalog_path: catalog_path
		catalog_url: catalog_url
	}

	core.scaffold(opts) or {
		eprintln(err)
		exit(1)
	}
	println('Scaffolded ${project}')
}

fn apply_env(offline bool, no_cache bool, cache_dir string, refresh string, strict bool) {
	if offline {
		os.setenv('CVA_OFFLINE', '1', true)
	}
	if no_cache {
		os.setenv('CVA_NO_CATALOG_CACHE', '1', true)
	}
	if cache_dir != '' {
		os.setenv('CVA_CACHE_DIR', cache_dir, true)
	}
	if refresh != '' {
		os.setenv('CVA_REFRESH', refresh, true)
	}
	if strict {
		os.setenv('CVA_STRICT_VERSION', '1', true)
	}
}

fn run_cache_cmd(args []string) {
	if args.len == 0 {
		eprintln('cache commands: dir|list|clean|verify|outdated|update|doctor')
		exit(2)
	}
	cmd := args[0]
	dir := core.default_cache_dir()
	match cmd {
		'dir' {
			println(dir)
		}
		'list' {
			if !os.is_dir(dir) {
				println('(empty)')
				return
			}
			entries := os.ls(os.join_path(dir, 'git')) or { []string{} }
			for e in entries {
				println(e)
			}
		}
		'clean' {
			os.rmdir_all(dir) or {}
			println('cleaned ${dir}')
		}
		'verify', 'outdated', 'update', 'doctor' {
			println('${cmd}: ok (stub)')
		}
		else {
			eprintln('unknown cache command: ${cmd}')
			exit(2)
		}
	}
}
