# bash completion for create-vlang-app
_create_vlang_app() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local opts="--help --version --info --template --addons --extend --force --no-install --no-interactive --list-templates --list-addons --catalog-path --catalog-url --cache-dir --offline --verbose cache"
  COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}
complete -F _create_vlang_app create-vlang-app
