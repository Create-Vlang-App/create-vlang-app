module create_vlang_app_core

fn test_public_constants() {
	assert version.len > 0
	assert env_prefix == 'CVA_'
	assert default_catalog_url.contains('cva-templates')
}
