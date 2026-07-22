module create_vlang_app_core

import os

pub struct VModMeta {
pub mut:
	name         string
	description  string
	version      string
	license      string
	dependencies []string
}

pub fn parse_vmod(text string) VModMeta {
	mut m := VModMeta{}
	m.name = capture_field(text, 'name')
	m.description = capture_field(text, 'description')
	m.version = capture_field(text, 'version')
	m.license = capture_field(text, 'license')
	m.dependencies = capture_deps(text)
	return m
}

fn capture_field(text string, field string) string {
	// name: 'foo'
	needle := field + ':'
	idx := text.index(needle) or { return '' }
	rest := text[idx + needle.len..].trim_space()
	if rest.starts_with("'") {
		end := rest.index_after("'", 1) or { return '' }
		return rest[1..end]
	}
	return ''
}

fn capture_deps(text string) []string {
	start := text.index('dependencies:') or { return [] }
	rest := text[start..]
	ob := rest.index('[') or { return [] }
	cb := rest.index_after(']', ob) or { return [] }
	inner := rest[ob + 1..cb]
	mut deps := []string{}
	for part in inner.split(',') {
		p :=
			part.trim_space().trim_string_left("'").trim_string_right("'").trim_string_left('"').trim_string_right('"')
		if p != '' {
			deps << p
		}
	}
	return deps
}

pub fn merge_vmod(base VModMeta, overlay VModMeta) VModMeta {
	mut out := base
	if overlay.name != '' {
		out.name = overlay.name
	}
	if overlay.description != '' {
		out.description = overlay.description
	}
	if overlay.version != '' {
		out.version = overlay.version
	}
	if overlay.license != '' {
		out.license = overlay.license
	}
	mut seen := map[string]bool{}
	mut deps := []string{}
	for d in base.dependencies {
		if !seen[d] {
			seen[d] = true
			deps << d
		}
	}
	for d in overlay.dependencies {
		if !seen[d] {
			seen[d] = true
			deps << d
		}
	}
	out.dependencies = deps
	return out
}

pub fn render_vmod(m VModMeta) string {
	mut deps := ''
	if m.dependencies.len > 0 {
		quoted := m.dependencies.map("'" + it + "'")
		deps = '[${quoted.join(', ')}]'
	} else {
		deps = '[]'
	}
	return "Module {\n\tname: '${m.name}'\n\tdescription: '${m.description}'\n\tversion: '${m.version}'\n\tlicense: '${m.license}'\n\tdependencies: ${deps}\n}\n"
}

pub fn merge_vmod_files(paths []string, dest string) ! {
	mut acc := VModMeta{}
	for p in paths {
		if !os.exists(p) {
			continue
		}
		text := os.read_file(p) or { continue }
		acc = merge_vmod(acc, parse_vmod(text))
	}
	os.write_file(dest, render_vmod(acc)) or {
		return error(new_error(code_install, 'write v.mod failed').msg())
	}
}
