module main

// brand_banner is a minimal terminal hero (ASCII, no emoji).
pub fn brand_banner() string {
	return 'create-vlang-app — scaffold V projects'
}

pub fn success_msg(project string) string {
	return 'OK  Scaffolded ${project}'
}

pub fn error_msg(err string) string {
	return 'ERR ${err}'
}
