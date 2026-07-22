# AUR RPC verification

After publish-aur pushes PKGBUILD:

```bash
curl -fsSL 'https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=create-vlang-app-bin'
```

Expect `resultcount` >= 1 once the package is registered.
