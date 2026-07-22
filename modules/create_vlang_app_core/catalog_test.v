module create_vlang_app_core

fn test_load_catalog_fixture() {
	cat := load_catalog_file('testdata/templates.json') or {
		assert false, err.str()
		return
	}
	assert list_template_names(cat).len == 2
	assert list_addon_names(cat).len == 1
	url, kind := resolve_slug(cat, 'minimal') or {
		assert false, err.str()
		return
	}
	assert kind == 'template'
	assert url.contains('file://')
	_, akind := resolve_slug(cat, 'github-setup') or {
		assert false, err.str()
		return
	}
	assert akind == 'addon'
}

fn test_unknown_slug() {
	cat := load_catalog_file('testdata/templates.json') or {
		assert false, err.str()
		return
	}
	resolve_slug(cat, 'nope') or {
		assert err.str().contains('unknown')
		return
	}
	assert false
}
