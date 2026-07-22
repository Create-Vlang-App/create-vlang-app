module create_vlang_app_core

import json
import net.http
import os

pub struct CatalogEntry {
pub:
	name        string
	description string
	url         string
	kind        string
	tags        []string
}

pub struct CatalogFile {
pub:
	templates []CatalogEntry
	addons    []CatalogEntry
}

pub fn load_catalog_json(raw string) !CatalogFile {
	return json.decode(CatalogFile, raw) or { return error('invalid catalog JSON: ${err}') }
}

pub fn load_catalog_file(path string) !CatalogFile {
	raw := os.read_file(path) or { return error('cannot read catalog ${path}: ${err}') }
	mut cat := load_catalog_json(raw)!
	root := os.dir(os.real_path(path))
	// If catalog is under fixtures/catalog, repo root is two levels up
	mut repo_root := root
	if os.file_name(root) == 'catalog' && os.file_name(os.dir(root)) == 'fixtures' {
		repo_root = os.dir(os.dir(root))
	} else if os.file_name(root) == 'testdata' {
		// modules/create_vlang_app_core/testdata -> repo root
		repo_root = os.dir(os.dir(os.dir(root)))
	}
	cat = expand_relative_file_urls(cat, repo_root)
	return cat
}

pub fn load_catalog_url(url string) !CatalogFile {
	resp := http.get(url) or { return error('catalog fetch failed: ${err}') }
	if resp.status_code < 200 || resp.status_code >= 300 {
		return error('catalog HTTP ${resp.status_code} for ${url}')
	}
	return load_catalog_json(resp.body)!
}

pub fn default_fixture_dir() string {
	env := os.getenv('CVA_FIXTURE_DIR')
	if env != '' {
		return env
	}
	// walk up from cwd for fixtures/catalog
	mut dir := os.getwd()
	for i := 0; i < 6; i++ {
		candidate := os.join_path(dir, 'fixtures', 'catalog')
		if os.is_dir(candidate) {
			return candidate
		}
		parent := os.dir(dir)
		if parent == dir {
			break
		}
		dir = parent
	}
	return os.join_path(os.getwd(), 'fixtures', 'catalog')
}

pub fn resolve_fixture_catalog_path(fixture_dir string) string {
	base := if fixture_dir != '' { fixture_dir } else { default_fixture_dir() }
	return os.join_path(base, 'templates.json')
}

pub fn resolve_catalog_source(catalog_path string, catalog_url string) (string, string) {
	if catalog_path != '' {
		return 'file', catalog_path
	}
	if os.getenv('CVA_CATALOG_FIXTURE') == '1' || os.getenv('CVA_CATALOG_FIXTURE') == 'true' {
		return 'file', resolve_fixture_catalog_path(os.getenv('CVA_FIXTURE_DIR'))
	}
	if catalog_url != '' {
		return 'url', catalog_url
	}
	env := os.getenv('CVA_CATALOG_URL')
	if env != '' {
		return 'url', env
	}
	return 'url', default_catalog_url
}

pub fn load_catalog(catalog_path string, catalog_url string) !CatalogFile {
	kind, src := resolve_catalog_source(catalog_path, catalog_url)
	if kind == 'file' {
		return load_catalog_file(src)!
	}
	return load_catalog_url(src)!
}

fn expand_relative_file_urls(cat CatalogFile, repo_root string) CatalogFile {
	mut templates := []CatalogEntry{}
	for t in cat.templates {
		templates << CatalogEntry{
			name: t.name
			description: t.description
			url: expand_file_url(t.url, repo_root)
			kind: t.kind
			tags: t.tags
		}
	}
	mut addons := []CatalogEntry{}
	for a in cat.addons {
		addons << CatalogEntry{
			name: a.name
			description: a.description
			url: expand_file_url(a.url, repo_root)
			kind: a.kind
			tags: a.tags
		}
	}
	return CatalogFile{
		templates: templates
		addons: addons
	}
}

fn expand_file_url(url string, repo_root string) string {
	if !url.starts_with('file://./') && !url.starts_with('file://modules/') {
		return url
	}
	rel := if url.starts_with('file://./') {
		url.all_after('file://./')
	} else {
		url.all_after('file://')
	}
	abs := os.real_path(os.join_path(repo_root, rel))
	return 'file://${abs}'
}

pub fn resolve_slug(catalog CatalogFile, slug string) !(string, string) {
	for t in catalog.templates {
		if t.name == slug {
			return t.url, 'template'
		}
	}
	for a in catalog.addons {
		if a.name == slug {
			return a.url, 'addon'
		}
	}
	return error('unknown catalog slug: ${slug}')
}

pub fn list_template_names(catalog CatalogFile) []string {
	mut names := []string{}
	for t in catalog.templates {
		names << t.name
	}
	return names
}

pub fn list_addon_names(catalog CatalogFile) []string {
	mut names := []string{}
	for a in catalog.addons {
		names << a.name
	}
	return names
}

pub fn format_catalog_list(title string, names []string) string {
	mut lines := ['${title}:']
	if names.len == 0 {
		lines << '  (none)'
		return lines.join('\n')
	}
	for n in names {
		lines << '  - ${n}'
	}
	return lines.join('\n')
}

pub fn resolve_user_spec(spec string, catalog CatalogFile) !string {
	src := resolve_source(spec)
	if src.kind != 'slug' {
		return spec
	}
	url, _ := resolve_slug(catalog, spec)!
	return url
}

pub fn spec_needs_catalog(spec string) bool {
	return resolve_source(spec).kind == 'slug'
}
