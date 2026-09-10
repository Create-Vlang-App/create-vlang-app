module create_vlang_app_core

import os

fn test_check_latest_offline() {
	os.setenv('CVA_OFFLINE', '1', true)
	assert check_latest_release('Create-Vlang-App', 'create-vlang-app') == ''
	os.unsetenv('CVA_OFFLINE')
}

fn test_parse_v_version() {
	assert parse_v_version('V 0.5.2 7647ce1') or { '' } == '0.5.2'
	assert parse_v_version('V 0.5.1\n') or { '' } == '0.5.1'
	if _ := parse_v_version('garbage') {
		assert false, 'expected error for garbage input'
	} else {
		assert err.str().contains('CVA_V_TOOLCHAIN')
	}
}

fn test_verify_v_toolchain_matches_or_reports() {
	det := verify_v_toolchain() or {
		assert err.str().contains('CVA_V_TOOLCHAIN')
		assert err.str().contains(required_v_version)
		return
	}
	assert det == required_v_version
}
