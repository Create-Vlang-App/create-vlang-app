module create_vlang_app_core

fn test_parse_empty() {
	cfg := parse_cva_config('') or { panic(err) }
	assert cfg.raw_json == ''
}

fn test_parse_object() {
	cfg := parse_cva_config('{"apiPrefix":"/api"}') or { panic(err) }
	assert cfg.has_key('apiPrefix')
}

fn test_parse_invalid() {
	parse_cva_config('[1,2]') or {
		assert err.msg().contains('CVA_CONFIG_PARSE')
		return
	}
	assert false
}
