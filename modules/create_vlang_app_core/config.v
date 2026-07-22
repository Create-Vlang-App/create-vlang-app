module create_vlang_app_core

import os

pub struct CustomOption {
pub:
	name        string
	typ         string
	default     string
	description string
}

pub struct CvaConfig {
pub mut:
	custom_options []CustomOption
	raw_json       string
}

pub fn load_cva_config(path string) !CvaConfig {
	if !os.exists(path) {
		return CvaConfig{}
	}
	text := os.read_file(path) or {
		return error(new_error(code_config_parse, 'cannot read ${path}').msg())
	}
	return parse_cva_config(text)
}

pub fn parse_cva_config(text string) !CvaConfig {
	trimmed := text.trim_space()
	if trimmed == '' {
		return CvaConfig{}
	}
	if !(trimmed.starts_with('{') && trimmed.ends_with('}')) {
		return error(new_error(code_config_parse, 'cva.config.json must be a JSON object').msg())
	}
	return CvaConfig{
		raw_json: trimmed
	}
}

pub fn (c CvaConfig) has_key(key string) bool {
	return c.raw_json.contains('"${key}"')
}
