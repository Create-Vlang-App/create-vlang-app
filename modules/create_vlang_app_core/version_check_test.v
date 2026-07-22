module create_vlang_app_core

import os

fn test_check_latest_offline() {
	os.setenv('CVA_OFFLINE', '1', true)
	assert check_latest_release('Create-Vlang-App', 'create-vlang-app') == ''
	os.unsetenv('CVA_OFFLINE')
}
