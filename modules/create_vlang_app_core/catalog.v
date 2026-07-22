module create_vlang_app_core

import json
import net.http
import os

// CatalogEntry is one template or addon listed in templates.json.
pub struct CatalogEntry {
pub:
	name        string
	description string
	url         string
	kind        string // template | addon
	tags        []string
}

pub struct CatalogFile {
pub:
	templates []CatalogEntry
	addons    []CatalogEntry
}

// load_catalog_json parses a templates.json document.
pub fn load_catalog_json(raw string) !CatalogFile {
	return json.decode(CatalogFile, raw) or { return error('invalid catalog JSON: ${err}') }
}

// load_catalog_file reads templates.json from disk.
pub fn load_catalog_file(path string) !CatalogFile {
	raw := os.read_file(path) or { return error('cannot read catalog ${path}: ${err}') }
	return load_catalog_json(raw)!
}

// load_catalog_url fetches and parses a remote catalog.
pub fn load_catalog_url(url string) !CatalogFile {
	resp := http.get(url) or { return error('catalog fetch failed: ${err}') }
	if resp.status_code < 200 || resp.status_code >= 300 {
		return error('catalog HTTP ${resp.status_code} for ${url}')
	}
	return load_catalog_json(resp.body)!
}

// resolve_catalog_path picks file path, CVA_CATALOG_URL, or default remote URL.
pub fn resolve_catalog_source(catalog_path string, catalog_url string) (string, string) {
	if catalog_path != '' {
		return 'file', catalog_path
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

// load_catalog loads from path or URL according to resolve_catalog_source.
pub fn load_catalog(catalog_path string, catalog_url string) !CatalogFile {
	kind, src := resolve_catalog_source(catalog_path, catalog_url)
	if kind == 'file' {
		return load_catalog_file(src)!
	}
	return load_catalog_url(src)!
}

// resolve_slug looks up a template or addon slug and returns its URL.
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

// list_template_names returns template names from the catalog.
pub fn list_template_names(catalog CatalogFile) []string {
	mut names := []string{}
	for t in catalog.templates {
		names << t.name
	}
	return names
}

// list_addon_names returns addon names from the catalog.
pub fn list_addon_names(catalog CatalogFile) []string {
	mut names := []string{}
	for a in catalog.addons {
		names << a.name
	}
	return names
}

// format_catalog_list pretty-prints names for CLI output.
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


// resolve_user_spec turns a slug into a catalog URL; passes through URLs unchanged.
pub fn resolve_user_spec(spec string, catalog CatalogFile) !string {
	src := resolve_source(spec)
	if src.kind != 'slug' {
		return spec
	}
	url, _ := resolve_slug(catalog, spec)!
	return url
}

// spec_needs_catalog is true when the spec is a bare slug.
pub fn spec_needs_catalog(spec string) bool {
	return resolve_source(spec).kind == 'slug'
}
