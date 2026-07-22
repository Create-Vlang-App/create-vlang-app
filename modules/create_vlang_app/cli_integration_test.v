module main

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
	res := os.execute('"${bin}" "${dst}" --template file://${src} --no-interactive --force --no-install')
	assert res.exit_code == 0, res.output
	assert os.exists(os.join_path(dst, 'v.mod'))
}

fn test_scaffold_via_slug() {
	repo := os.dir(os.dir(os.dir(@FILE)))
	bin := os.join_path(repo, 'create-vlang-app')
	dst := os.join_path(os.temp_dir(), 'cva-cli-int-slug')
	os.rmdir_all(dst) or {}
	res := os.execute('"${bin}" "${dst}" --template minimal --addons github-setup --fixture --no-interactive --force --no-install')
	assert res.exit_code == 0, res.output
	assert os.exists(os.join_path(dst, 'v.mod'))
	assert os.exists(os.join_path(dst, 'src/addon.v'))
}
