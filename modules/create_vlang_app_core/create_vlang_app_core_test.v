module create_vlang_app_core

fn test_hello() {
	assert hello() == 'create-vlang-app-core'
}

fn test_version() {
	assert version.len > 0
}
