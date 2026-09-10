module main

import json
import os

fn test_help_and_version_smoke() {
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	os.execute('make -C "${repo}" build')
	h := os.execute('"${bin}" --help')
	assert h.exit_code == 0
	assert h.output.contains('create-vlang-app')
	v := os.execute('"${bin}" --version')
	assert v.exit_code == 0
}

fn test_scaffold_file_url() {
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	src := os.join_path(repo, 'modules/create_vlang_app_core/testdata/layers/base')
	dst := os.join_path(os.temp_dir(), 'cva-cli-int-file')
	os.rmdir_all(dst) or {}
	res :=
		os.execute('"${bin}" "${dst}" --template file://${src} --no-interactive --force --no-install')
	assert res.exit_code == 0, res.output
	assert os.exists(os.join_path(dst, 'v.mod'))
}

fn test_scaffold_via_slug() {
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	dst := os.join_path(os.temp_dir(), 'cva-cli-int-slug')
	os.rmdir_all(dst) or {}
	res :=
		os.execute('"${bin}" "${dst}" --template minimal --addons github-setup --fixture --no-interactive --force --no-install')
	assert res.exit_code == 0, res.output
	assert os.exists(os.join_path(dst, 'v.mod'))
	assert os.exists(os.join_path(dst, 'src/addon.v'))
}

fn test_skip_install_alias() {
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	h := os.execute('"${bin}" --help')
	assert h.exit_code == 0
	assert h.output.contains('--skip-install')
	src := os.join_path(repo, 'modules/create_vlang_app_core/testdata/layers/base')
	dst := os.join_path(os.temp_dir(), 'cva-cli-int-skip-install')
	os.rmdir_all(dst) or {}
	res :=
		os.execute('"${bin}" "${dst}" --template file://${src} --no-interactive --force --skip-install')
	assert res.exit_code == 0, res.output
	assert os.exists(os.join_path(dst, 'v.mod'))
}

fn test_help_shows_examples() {
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	h := os.execute('"${bin}" --help')
	assert h.exit_code == 0
	assert h.output.contains('Examples:')
	assert h.output.contains('--template web-server --addons github-setup')
	assert h.output.contains('create-awesome-vlang-app my-app')
	assert h.output.contains('install.sh')
}

fn test_list_json_output() {
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	t := os.execute('"${bin}" --list-templates --json --fixture --no-interactive')
	assert t.exit_code == 0, t.output
	templates := json.decode([]string, t.output.trim_space()) or {
		assert false, 'templates output is not a JSON array: ${t.output}'
		return
	}
	assert 'minimal' in templates
	a := os.execute('"${bin}" --list-addons --json --fixture --no-interactive')
	assert a.exit_code == 0, a.output
	addons := json.decode([]string, a.output.trim_space()) or {
		assert false, 'addons output is not a JSON array: ${a.output}'
		return
	}
	assert 'github-setup' in addons
	b := os.execute('"${bin}" --list-templates --list-addons --json --fixture --no-interactive')
	assert b.exit_code == 0, b.output
	both := json.decode(map[string][]string, b.output.trim_space()) or {
		assert false, 'combined output is not a JSON object: ${b.output}'
		return
	}
	assert 'minimal' in both['templates']
	assert 'github-setup' in both['addons']
}

fn test_list_templates_category_filter() {
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	ok := os.execute('"${bin}" --list-templates --category web --fixture --no-interactive')
	assert ok.exit_code == 0, ok.output
	assert ok.output.contains('web-server')
	assert !ok.output.contains('minimal')
	j := os.execute('"${bin}" --list-templates --category web --json --fixture --no-interactive')
	assert j.exit_code == 0, j.output
	filtered := json.decode([]string, j.output.trim_space()) or {
		assert false, 'filtered output is not a JSON array: ${j.output}'
		return
	}
	assert filtered == ['web-server']
	bad := os.execute('"${bin}" --list-templates --category nope --fixture --no-interactive')
	assert bad.exit_code == 1
	assert bad.output.contains('no templates found')
}

fn test_v_version_check_missing_toolchain() {
	if os.user_os() == 'windows' {
		return
	}
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	dst := os.join_path(os.temp_dir(), 'cva-cli-int-vcheck')
	os.rmdir_all(dst) or {}
	res :=
		os.execute('env PATH=/usr/bin:/bin "${bin}" "${dst}" --template minimal --fixture --no-interactive')
	assert res.exit_code == 1, res.output
	assert res.output.contains('V toolchain not found')
	required := os.read_file(os.join_path(repo, '.v-version')) or { '' }.trim_space()
	assert required != ''
	assert res.output.contains(required)
}
