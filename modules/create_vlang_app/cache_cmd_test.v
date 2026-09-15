module main

import json
import os

fn test_cache_cmds_empty_cache_json() {
	if os.user_os() == 'windows' {
		return
	}
	repo := os.dir(os.dir(os.dir(@FILE)))
	os.execute('make -C "${repo}" build')
	bin := os.join_path(repo, 'create-vlang-app')
	dir := os.join_path(os.temp_dir(), 'cva-cache-cmd-test')
	os.rmdir_all(dir) or {}
	v := os.execute('CVA_CACHE_DIR="${dir}" "${bin}" cache verify --json --no-interactive')
	assert v.exit_code == 0, v.output
	assert v.output.contains('"ok":true')
	o := os.execute('CVA_CACHE_DIR="${dir}" "${bin}" cache outdated --json --no-interactive')
	assert o.exit_code == 0, o.output
	outdated := json.decode(map[string][]string{}, o.output.trim_space()) or {
		assert false, 'outdated output is not JSON: ${o.output}'
		return
	}
	assert outdated['outdated'] == []
	d := os.execute('CVA_CACHE_DIR="${dir}" "${bin}" cache doctor --json --no-interactive')
	assert d.exit_code == 0, d.output
	assert d.output.contains('"cache_dir"')
	u := os.execute('CVA_CACHE_DIR="${dir}" "${bin}" cache update --json --no-interactive')
	assert u.exit_code == 0, u.output
	assert u.output.contains('"updated":true')
	assert os.exists(os.join_path(dir, '.refresh-always'))
}
