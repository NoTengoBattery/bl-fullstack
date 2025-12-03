#!/usr/bin/env -S zsh --login
set -xeuo pipefail

# Ensure necessary files exist to avoid errors and mark the repository as safe
touch Gemfile Gemfile.lock package.json yarn.lock
git config --global --add safe.directory $(pwd)

# Set up environment variables for Bundler and Yarn in rootless mode
export BUNDLE_PATH=$HOME/.bundle
export YARN_BIN=$HOME/node_modules/.bin
echo export BUNDLE_PATH=\"$BUNDLE_PATH\" >>$HOME/.zshenv
echo export BUNDLE_BIN=\"$BUNDLE_PATH/bin\" >>$HOME/.zshenv
echo export YARN_BIN=\"$YARN_BIN\" >>$HOME/.zshenv
source $HOME/.zshenv
echo export PATH=\"\$PATH:\$BUNDLE_BIN:\$YARN_BIN\" >$HOME/.zprofile
source $HOME/.zprofile

# Environment-specific commands and packages (Yarn)
case $RAILS_ENV in
production | staging)
  :
  ;;
test)
  :
  ;;
*)
  :
  ;;
esac

yarn install

# Install the Ruby dependencies with Bundler
BUNDLE_DEPLOY="false"
bundle config set --local path $BUNDLE_PATH

# Environment-specific commands and packages (Bundler)
case $RAILS_ENV in
production | staging)
  BUNDLE_IGNORE="development test"
  BUNDLE_DEPLOY="true"
  ;;
test)
  BUNDLE_IGNORE="development"
  BUNDLE_DEPLOY="true"
  ;;
*)
  :
  ;;
esac

[[ -v BUNDLE_IGNORE ]] && bundle config set --local without ${=BUNDLE_IGNORE}
bundle config set --local deployment $BUNDLE_DEPLOY
bundle install

# Clean up build context to reduce image size
rm -rf ./*(D)

exit 0
