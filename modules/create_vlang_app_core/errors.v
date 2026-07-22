module create_vlang_app_core

pub struct CvaError {
pub:
	code    string
	message string
}

pub fn (e CvaError) msg() string {
	return '[${e.code}] ${e.message}'
}

pub fn new_error(code string, message string) CvaError {
	return CvaError{
		code:    code
		message: message
	}
}

pub const code_error = 'CVA_ERROR'
pub const code_config_parse = 'CVA_CONFIG_PARSE'
pub const code_manifest_load = 'CVA_MANIFEST_LOAD'
pub const code_aborted = 'CVA_ABORTED'
pub const code_non_empty_target = 'CVA_NON_EMPTY_TARGET_DIR'
pub const code_incompatible_ext = 'CVA_INCOMPATIBLE_EXTENSIONS'
pub const code_strict_repro = 'CVA_STRICT_REPRO'
pub const code_path_resolve = 'CVA_PATH_RESOLVE'
pub const code_git_cache = 'CVA_GIT_CACHE'
pub const code_install = 'CVA_INSTALL'

// abort_with prints the error and exits the process with code 1.
pub fn abort_with(err CvaError) {
	eprintln(err.msg())
	exit(1)
}
