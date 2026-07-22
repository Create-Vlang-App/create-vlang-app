module create_vlang_app_core

// version is the core library semver (keep in sync with v.mod).
pub const version = '0.0.1'

// hello returns a stub identity string used by smoke tests.
pub fn hello() string {
	return 'create-vlang-app-core'
}

// env_prefix is the shared environment variable prefix (CVA_*).
pub const env_prefix = 'CVA_'

// default_catalog_url points at the official templates bank (raw templates.json).
pub const default_catalog_url = 'https://raw.githubusercontent.com/Create-Vlang-App/cva-templates/main/templates.json'
