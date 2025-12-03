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

# Update Node.js and Yarn to the latest versions
npm install --global npm@latest
npm install --global yarn@latest
npm update --global

# Clean up build context to reduce image size
rm -rf ./*(D)

exit 0
