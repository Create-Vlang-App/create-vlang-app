# Contribuyendo a create-vlang-app

¡Gracias por contribuir!

## Requisitos previos

- [V](https://vlang.io) que coincida con [`.v-version`](.v-version) (`v version`)
- `make`, `git`
- Opcional: `pre-commit` (`pre-commit install`)

## Configuración

```bash
git clone https://github.com/Create-Vlang-App/create-vlang-app.git
cd create-vlang-app
make test
make build
```

## Flujo de trabajo

1. Abre o usa un issue existente en GitHub.
2. Crea una rama desde `main`: `feat/<issue>-short-slug`.
3. Haz un cambio enfocado (un issue por PR).
4. Ejecuta `make fmt-check vet test build`.
5. Abre un PR **listo para revisión** con `Closes #<issue>`.
6. Espera la CI (y la revisión de IA si está configurada) antes de fusionar.

## Estilo de código

- Ejecuta `v fmt` / `make fmt`.
- Prefiere nombres claros sobre la ingeniosidad.
- Inglés para commits, PRs y documentación.

## VPM

La distribución principal es VPM (`v install create-vlang-app`). No asumas flujos de trabajo de npm/PyPI.

## Plantillas

Las plantillas y extensiones oficiales viven en el repositorio
[`cva-templates`](https://github.com/Create-Vlang-App/cva-templates).
Los cambios en las plantillas (catálogo, `templates.json`, scaffolds) se hacen allí, no aquí.
