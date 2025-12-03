#!/usr/bin/env -S zsh --login
set -xeuo pipefail

# Even if uninstalling software won't free space in a docker container, it is very important to remove ceirtain tools
# such as the C compiler, as they can be easily become an attack vector.

# Uninstall build dependencies that are no longer needed

# Environment-specific commands and packages
case $RAILS_ENV in
production | staging)
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false build-essential libclang-dev rustc
  ;;
test)
  :
  ;;
*)
  :
  ;;
esac

# Clean up build context to reduce image size
rm -rf ./*(D)

exit 0
