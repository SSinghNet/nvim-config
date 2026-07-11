#!/usr/bin/env bash
# One-time (idempotent) setup for WordPress PHP linting/formatting.
#
# The nvim config (see lua/plugins/nvim-lint.lua and lua/plugins/conform.lua) runs
# `phpcs`/`phpcbf --standard=WordPress` on files under wp-admin/wp-includes/wp-content.
# That standard ships in a separate composer package (wp-coding-standards/wpcs) and has
# to be registered with phpcs'/phpcbf's `installed_paths` config -- this can't be done from
# Lua, and mason installs phpcs/phpcbf as two separate, independently-configured packages
# (each with its own isolated CodeSniffer.conf), so a global `phpcs --config-set` elsewhere
# on the machine won't reach either of them. This script does both steps against both of
# mason's installs specifically, so it stays in sync with whatever this config uses.
set -euo pipefail

if ! command -v composer >/dev/null 2>&1; then
  echo "error: composer not found on PATH -- install it first (https://getcomposer.org)" >&2
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "error: nvim not found on PATH" >&2
  exit 1
fi

if ! command -v php >/dev/null 2>&1; then
  echo "error: php not found on PATH" >&2
  exit 1
fi

data_dir=$(nvim --headless --clean -c 'lua io.write(vim.fn.stdpath("data"))' -c 'qa' 2>/dev/null)
phpcs_bin="$data_dir/mason/bin/phpcs"
phpcbf_bin="$data_dir/mason/bin/phpcbf"

for bin in "$phpcs_bin" "$phpcbf_bin"; do
  if [ ! -x "$bin" ]; then
    echo "error: $bin not found -- open nvim once so mason-tool-installer can install phpcs/phpcbf" >&2
    exit 1
  fi
done

echo "Installing wp-coding-standards/wpcs via global composer..."
composer global require --no-interaction --quiet "wp-coding-standards/wpcs"

# wpcs depends on PHPCSUtils/PHPCSExtra, so every "phpcodesniffer-standard" package in the
# global composer install needs its path registered, not just wpcs's own -- otherwise sniffs
# that use PHPCSUtils (e.g. NonceVerificationSniff) fatal error with "Class PHPCSUtils\...
# not found". A normal project-local phpcs gets this for free from the
# dealerdirect/phpcodesniffer-composer-installer plugin; mason's standalone phars don't share
# that vendor dir, so it's resolved and registered by hand here.
composer_home=$(composer config --global home 2>/dev/null)
installed_json="$composer_home/vendor/composer/installed.json"

required_paths=()
while IFS= read -r name; do
  path=$(composer global show "$name" --path 2>/dev/null | awk '{print $NF}')
  [ -n "$path" ] && required_paths+=("$path")
done < <(php -r '
$data = json_decode(file_get_contents($argv[1]), true);
$pkgs = $data["packages"] ?? $data;
foreach ($pkgs as $p) {
  if (($p["type"] ?? "") === "phpcodesniffer-standard") {
    echo $p["name"] . "\n";
  }
}
' "$installed_json")

if [ "${#required_paths[@]}" -eq 0 ]; then
  echo "error: could not resolve any phpcodesniffer-standard package paths from $installed_json" >&2
  exit 1
fi

contains() {
  local needle="$1"; shift
  for x in "$@"; do [ "$x" = "$needle" ] && return 0; done
  return 1
}

for bin in "$phpcs_bin" "$phpcbf_bin"; do
  existing=$("$bin" --config-show 2>/dev/null | sed -n 's/^installed_paths: //p')
  new_paths=("${required_paths[@]}")
  if [ -n "$existing" ]; then
    IFS=',' read -ra paths <<<"$existing"
    for p in "${paths[@]}"; do
      [ -n "$p" ] && ! contains "$p" "${new_paths[@]}" && new_paths+=("$p")
    done
  fi
  joined=$(IFS=,; echo "${new_paths[*]}")

  echo "Registering installed_paths with $bin..."
  "$bin" --config-set installed_paths "$joined"

  if ! "$bin" -i | grep -qw "WordPress"; then
    echo "warning: ran setup but 'WordPress' standard not listed by '$bin -i':" >&2
    "$bin" -i >&2
    exit 1
  fi
done

echo "Done -- WordPress standard is available for phpcs and phpcbf: $("$phpcs_bin" -i)"
