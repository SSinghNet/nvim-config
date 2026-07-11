#!/usr/bin/env bash
# One-time (idempotent) setup for WordPress PHP linting/formatting.
#
# The nvim config (see lua/plugins/nvim-lint.lua and lua/plugins/conform.lua) runs
# `phpcs`/`phpcbf --standard=WordPress` on files under wp-admin/wp-includes/wp-content.
# That standard ships in a separate composer package (wp-coding-standards/wpcs) and has
# to be registered with phpcs' `installed_paths` config -- this can't be done from Lua,
# and mason's phpcs/phpcbf installs are isolated copies, so a global `phpcs --config-set`
# elsewhere on the machine won't reach them. This script does both steps against
# mason's install specifically, so it stays in sync with whatever this config uses.
set -euo pipefail

if ! command -v composer >/dev/null 2>&1; then
  echo "error: composer not found on PATH -- install it first (https://getcomposer.org)" >&2
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "error: nvim not found on PATH" >&2
  exit 1
fi

data_dir=$(nvim --headless --clean -c 'lua io.write(vim.fn.stdpath("data"))' -c 'qa' 2>/dev/null)
phpcs_bin="$data_dir/mason/bin/phpcs"

if [ ! -x "$phpcs_bin" ]; then
  echo "error: $phpcs_bin not found -- open nvim once so mason-tool-installer can install phpcs/phpcbf" >&2
  exit 1
fi

echo "Installing wp-coding-standards/wpcs via global composer..."
composer global require --no-interaction --quiet "wp-coding-standards/wpcs"

wpcs_path=$(composer global show wp-coding-standards/wpcs --path 2>/dev/null | awk '{print $NF}')
if [ -z "$wpcs_path" ]; then
  echo "error: could not resolve install path for wp-coding-standards/wpcs" >&2
  exit 1
fi

existing=$("$phpcs_bin" --config-show 2>/dev/null | sed -n 's/^installed_paths: //p')
IFS=',' read -ra paths <<<"${existing:-}"
new_paths=("$wpcs_path")
for p in "${paths[@]}"; do
  [ -n "$p" ] && [ "$p" != "$wpcs_path" ] && new_paths+=("$p")
done
joined=$(IFS=,; echo "${new_paths[*]}")

echo "Registering installed_paths with mason's phpcs ($phpcs_bin)..."
"$phpcs_bin" --config-set installed_paths "$joined"

if "$phpcs_bin" -i | grep -qw "WordPress"; then
  echo "Done -- WordPress standard is available: $("$phpcs_bin" -i)"
else
  echo "warning: ran setup but 'WordPress' standard not listed by 'phpcs -i':" >&2
  "$phpcs_bin" -i >&2
  exit 1
fi
