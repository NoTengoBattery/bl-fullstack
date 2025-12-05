#!/usr/bin/env -S zsh --login
set -xeuo pipefail

# Environment-specific commands and packages
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

# Clean up build context to reduce image size
rm -rf ./*(D)

exit 0
