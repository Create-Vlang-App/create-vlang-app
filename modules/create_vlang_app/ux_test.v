module main

fn test_brand_banner() {
	assert brand_banner().contains('create-vlang-app')
}

fn test_success_msg() {
	assert success_msg('/tmp/x').starts_with('OK')
}
