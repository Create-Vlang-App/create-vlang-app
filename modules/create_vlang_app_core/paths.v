module create_vlang_app_core

import os

pub struct ResolvedSource {
pub:
	kind       string // github | file | slug | git
	url        string
	ref        string
	subdir     string
	local_path string
}

pub fn default_cache_dir() string {
	override := os.getenv('CVA_CACHE_DIR')
	if override != '' {
		return os.real_path(override)
	}
	return os.join_path(os.home_dir(), '.cache', 'cva')
}

fn query_param(spec string, key string) string {
	if !spec.contains('?') {
		return ''
	}
	q := spec.all_after('?')
	parts := q.split('&')
	for p in parts {
		if p.starts_with(key + '=') {
			return p.all_after('=')
		}
	}
	return ''
}

fn parse_ref(spec string) string {
	mut ref := query_param(spec, 'ref')
	if ref == '' {
		ref = query_param(spec, 'branch')
	}
	if ref == '' {
		ref = query_param(spec, 'tag')
	}
	if os.getenv('CVA_STRICT_REPRO') == '1' && ref != '' && ref.len != 40 {
		abort_with(new_error(code_strict_repro, 'expected full 40-char SHA, got ${ref}'))
	}
	return ref
}

// resolve_source resolves GitHub URL, file://, or legacy slug specs.
pub fn resolve_source(spec string) ResolvedSource {
	if spec.starts_with('file://') {
		mut path := spec.all_after('file://').all_before('?')
		// file:///tmp/x -> /tmp/x
		if path.starts_with('/') && path.len > 1 && !path.starts_with('//') {
			// already absolute unix path with one leading slash from file:///
		}
		if path.starts_with('//') {
			path = path[1..] // file://localhost/tmp -> /localhost/tmp uncommon
		}
		// Normalize file:///abs
		if spec.starts_with('file:///') {
			path = '/' + spec.all_after('file:///').all_before('?')
		}
		return ResolvedSource{
			kind:       'file'
			url:        spec
			ref:        parse_ref(spec)
			subdir:     query_param(spec, 'subdir')
			local_path: path
		}
	}

	if spec.contains('://') || spec.starts_with('git@') {
		base := spec.all_before('?')
		mut kind := 'git'
		if base.contains('github.com/') {
			kind = 'github'
		}
		return ResolvedSource{
			kind:   kind
			url:    base
			ref:    parse_ref(spec)
			subdir: query_param(spec, 'subdir')
		}
	}

	return ResolvedSource{
		kind: 'slug'
		url:  spec
	}
}

// get_template_dir_path prefers a nested template/ directory when present.
pub fn get_template_dir_path(source ResolvedSource, root string) string {
	mut base := root
	if source.subdir != '' {
		base = os.join_path(root, source.subdir)
	}
	candidate := os.join_path(base, 'template')
	if os.is_dir(candidate) {
		return candidate
	}
	return base
}
