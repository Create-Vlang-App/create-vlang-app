# Shell completions

Static completion scripts live under `completions/`:

| Shell | File |
|-------|------|
| bash | `completions/create-vlang-app.bash` |
| zsh | `completions/create-vlang-app.zsh` |
| fish | `completions/create-vlang-app.fish` |

## Install (examples)

```bash
# bash
source completions/create-vlang-app.bash

# zsh
fpath+=("$PWD/completions")
autoload -U compinit && compinit

# fish
cp completions/create-vlang-app.fish ~/.config/fish/completions/
```

Smoke: after sourcing bash completion, `create-vlang-app --<TAB>` should offer flags.
