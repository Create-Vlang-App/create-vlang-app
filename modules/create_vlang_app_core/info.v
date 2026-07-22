module create_vlang_app_core

import os

pub fn env_info() string {
	mut lines := []string{}
	lines << 'create-vlang-app-core ${version}'
	v_out := os.execute('v version')
	lines << 'v: ${v_out.output.trim_space()}'
	lines << 'CVA_CACHE_DIR=${default_cache_dir()}'
	lines << 'CVA_REFRESH=${os.getenv('CVA_REFRESH')}'
	lines << 'CVA_OFFLINE=${os.getenv('CVA_OFFLINE')}'
	lines << 'CVA_STRICT_VERSION=${os.getenv('CVA_STRICT_VERSION')}'
	return lines.join('\n')
}
