module create_vlang_app_core

fn test_error_msg_format() {
	e := new_error(code_aborted, 'stopped')
	assert e.msg().contains('CVA_ABORTED')
	assert e.msg().contains('stopped')
}
