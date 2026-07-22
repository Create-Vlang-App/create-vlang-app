module main

import os
import flag
import json
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
	set_flag := fp.string('set', 0, '', 'set key=value (repeatable via raw args)')
	force := fp.bool('force', `f`, false, 'allow non-empty target directory / skip clean confirm')
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
	use_fixture := fp.bool('fixture', 0, false, 'use local fixtures/catalog templates.json')
	fixture_dir := fp.string('fixture-dir', 0, '', 'fixture catalog directory (implies --fixture)')
	add_completion := fp.string('add-completion', 0, '', 'print completion script: bash|zsh|fish')
	as_json := fp.bool('json', 0, false, 'JSON output for cache subcommands')

	additional := fp.finalize() or {
		eprintln(err)
		exit(2)
	}

	if add_completion != '' {
		print_completion(add_completion)
		return
	}

	if show_info {
		println(core.env_info())
		return
	}

	mut resolved_catalog_path := catalog_path
	if use_fixture || fixture_dir != '' {
		os.setenv('CVA_CATALOG_FIXTURE', '1', true)
		dir := if fixture_dir != '' { fixture_dir } else { os.getenv('CVA_FIXTURE_DIR') }
		resolved_catalog_path = core.resolve_fixture_catalog_path(dir)
	}

	apply_env(offline, no_cache, cache_dir, refresh, strict_version)

	if list_templates || list_addons {
		cat := core.load_catalog(resolved_catalog_path, catalog_url) or {
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

	if additional.len > 0 && additional[0] == 'cache' {
		run_cache_cmd(additional[1..], force, no_interactive, as_json)
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
	mut sets := []string{}
	if set_flag != '' {
		sets << set_flag
	}
	for i, a in os.args {
		if a == '--addons' || a == '--extend' {
			if i + 1 < os.args.len {
				val := os.args[i + 1]
				for part in val.split(',') {
					s := part.trim_space()
					if s != '' && !addons.contains(s) {
						addons << s
					}
				}
			}
		}
		if a == '--set' && i + 1 < os.args.len {
			sets << os.args[i + 1]
		}
	}
	_ = verbose

	mut project_dir := project
	mut tmpl := template_spec
	if use_interactive {
		if project_dir == '' {
			project_dir = prompt_styled('Project directory')
		}
		if tmpl == '' {
			tmpl = prompt_styled('Template (URL|file://|slug)')
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
		catalog_path: resolved_catalog_path
		catalog_url: catalog_url
	}

	core.scaffold(opts) or {
		eprintln(error_msg(err.str()))
		exit(1)
	}
	apply_sets(project_dir, sets)
	println(success_msg(project_dir))
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

fn apply_sets(project_dir string, sets []string) {
	if sets.len == 0 {
		return
	}
	cfg_path := os.join_path(project_dir, 'cva.config.json')
	mut data := map[string]string{}
	if os.exists(cfg_path) {
		raw := os.read_file(cfg_path) or { '{}' }
		// lightweight: store overlay keys in a simple JSON object as strings
		_ = raw
	}
	for item in sets {
		if !item.contains('=') {
			continue
		}
		k := item.all_before('=')
		v := item.all_after('=')
		data[k] = v
	}
	mut lines := ['{']
	keys := data.keys()
	for i, k in keys {
		comma := if i + 1 < keys.len { ',' } else { '' }
		lines << '  "${k}": "${data[k]}"${comma}'
	}
	lines << '}'
	os.write_file(cfg_path, lines.join('\n') + '\n') or {}
}

fn prompt_styled(label string) string {
	styled := style_label(label)
	return os.input('${styled}: ').trim_space()
}

fn style_label(label string) string {
	color := os.getenv('CVA_COLOR')
	if color == 'never' {
		return label
	}
	if color == 'always' || (color == '' && os.getenv('NO_COLOR') == '') {
		return '\x1b[1m${label}\x1b[0m'
	}
	return label
}

fn print_completion(shell string) {
	repo_hint := 'completions/create-vlang-app.${shell}'
	match shell {
		'bash', 'zsh', 'fish' {
			path := os.join_path(os.dir(os.executable()), '..', repo_hint)
			// Prefer packaged completions next to cwd
			for candidate in [
				os.join_path(os.getwd(), 'completions', 'create-vlang-app.${shell}'),
				path,
			] {
				if os.exists(candidate) {
					println(os.read_file(candidate) or { '' })
					return
				}
			}
			eprintln('completion file not found for ${shell}; see docs/COMPLETIONS.md')
			exit(1)
		}
		else {
			eprintln('supported shells: bash, zsh, fish')
			exit(2)
		}
	}
}

fn run_cache_cmd(args []string, force bool, no_interactive bool, json_flag bool) {
	if args.len == 0 {
		eprintln('cache commands: dir|list|clean|verify|outdated|update|doctor')
		exit(2)
	}
	mut as_json := json_flag
	mut cmd := args[0]
	mut rest := args[1..].clone()
	if cmd == '--json' && rest.len > 0 {
		as_json = true
		cmd = rest[0]
		rest = rest[1..].clone()
	}
	for a in rest {
		if a == '--json' {
			as_json = true
		}
	}

	dir := core.default_cache_dir()
	git_dir := os.join_path(dir, 'git')
	match cmd {
		'dir' {
			if as_json {
				println('{"cache_dir":"${dir}"}')
			} else {
				println(dir)
			}
		}
		'list' {
			entries := if os.is_dir(git_dir) { os.ls(git_dir) or { []string{} } } else { []string{} }
			if as_json {
				println(json.encode(entries))
			} else if entries.len == 0 {
				println('(empty)')
			} else {
				for e in entries {
					println(e)
				}
			}
		}
		'clean' {
			if !force && !no_interactive && os.is_atty(0) > 0 {
				ans := os.input('Are you sure you want to remove all cached entries? [y/N] ').trim_space().to_lower()
				if ans !in ['y', 'yes'] {
					println('aborted')
					return
				}
			}
			os.rmdir_all(dir) or {}
			if as_json {
				println('{"cleaned":true,"cache_dir":"${dir}"}')
			} else {
				println('cleaned ${dir}')
			}
		}
		'verify' {
			ok := !os.is_dir(git_dir) || (os.ls(git_dir) or { []string{} }).len >= 0
			if as_json {
				println('{"ok":${ok},"cache_dir":"${dir}"}')
			} else {
				println(if ok { 'verify: ok' } else { 'verify: failed' })
			}
		}
		'outdated' {
			entries := if os.is_dir(git_dir) { os.ls(git_dir) or { []string{} } } else { []string{} }
			if as_json {
				println('{"outdated":' + json.encode(entries) + '}')
			} else if entries.len == 0 {
				println('(none)')
			} else {
				for e in entries {
					println(e)
				}
			}
		}
		'update' {
			// refresh = always next fetch; mark by touching a stamp
			os.mkdir_all(dir) or {}
			stamp := os.join_path(dir, '.refresh-always')
			os.write_file(stamp, '1') or {}
			os.setenv('CVA_REFRESH', 'always', true)
			if as_json {
				println('{"updated":true,"refresh":"always"}')
			} else {
				println('update: refresh=always for next clone/fetch')
			}
		}
		'doctor' {
			v_ok := os.exists_in_system_path('v')
			git_ok := os.exists_in_system_path('git')
			if as_json {
				println('{"v":${v_ok},"git":${git_ok},"cache_dir":"${dir}"}')
			} else {
				println('doctor:')
				println('  v: ${v_ok}')
				println('  git: ${git_ok}')
				println('  cache: ${dir}')
			}
		}
		else {
			eprintln('unknown cache command: ${cmd}')
			exit(2)
		}
	}
}
