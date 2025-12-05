#!/usr/bin/env -S zsh --login
set -xeuo pipefail

[[ -v CI ]] && CI_OPTS="--fail-fast"


if [[ ! -v CI ]]; then
  bundle exec rspec --force-color --format documentation
else
  bin/rspec --force-color --format documentation ${=CI_OPTS} || {
    bin/rspec --force-color --format documentation ${=CI_OPTS} --bisect
    exit 1
  }
fi

# Check if the project has no Zeitwerk loading errors
bin/rails zeitwerk:check &
