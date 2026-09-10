module main

fn test_brand_banner() {
	assert brand_banner().contains('create-vlang-app')
}

fn test_success_msg() {
	assert success_msg('/tmp/x').starts_with('OK')
}

fn test_spinner_allowed_matrix() {
	assert spinner_allowed(false, true, true) == true
	assert spinner_allowed(true, true, true) == false
	assert spinner_allowed(false, false, true) == false
	assert spinner_allowed(false, true, false) == false
	assert spinner_allowed(true, false, false) == false
}

fn test_start_spinner_disabled_without_tty() {
	if _ := start_spinner('test', true) {
		assert false, 'spinner must not start without a TTY in tests'
	} else {
	}
	if _ := start_spinner('test', false) {
		assert false, 'spinner must not start when non-interactive'
	} else {
	}
}
