#compdef create-vlang-app
_arguments \
  '--help' '--version' '--info' \
  '--template[template spec]:spec:' \
  '--addons[addons]:spec:' \
  '--force' '--no-install' '--no-interactive' \
  '--list-templates' '--list-addons' \
  '--catalog-path[path]:file:_files' \
  '--catalog-url[url]:url:' \
  '1:project dir:_files -/' \
  'cache:cache cmd:(dir list clean verify outdated update doctor)'
