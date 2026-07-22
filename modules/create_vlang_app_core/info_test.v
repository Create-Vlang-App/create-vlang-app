module create_vlang_app_core

fn test_env_info_contains_version() {
	s := env_info()
	assert s.contains(version)
	assert s.contains('CVA_CACHE_DIR')
}
