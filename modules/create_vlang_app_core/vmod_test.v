module create_vlang_app_core

fn test_parse_and_merge_vmod() {
	a := parse_vmod("Module {\n\tname: 'a'\n\tversion: '0.1.0'\n\tdependencies: ['x']\n}\n")
	b := parse_vmod("Module {\n\tname: 'b'\n\tdependencies: ['y', 'x']\n}\n")
	m := merge_vmod(a, b)
	assert m.name == 'b'
	assert 'x' in m.dependencies
	assert 'y' in m.dependencies
	out := render_vmod(m)
	assert out.contains("name: 'b'")
}
