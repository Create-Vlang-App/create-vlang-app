# Release

Cut a tag:

```bash
git tag create-vlang-app@0.1.0
git push origin create-vlang-app@0.1.0
```

`.github/workflows/publish.yml` builds binaries and creates a GitHub Release.
