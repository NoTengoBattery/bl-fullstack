#!/usr/bin/env -S zsh --login
set -xeuo pipefail

# Configure APT to avoid installing recommended packages by default,
# always assume "yes" to prompts, and automatically remove unneeded packages
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/project-config
echo 'APT::Get::Assume-Yes "true";' >> /etc/apt/apt.conf.d/project-config
echo 'APT::Get::AutomaticRemove "true";' >> /etc/apt/apt.conf.d/project-config

# Update package lists and upgrade existing packages
apt-get update
apt-get upgrade

# Essential packages for building and shell environment
apt-get install apt-utils build-essential zsh

# Command line tools and clients utilities, cool stuff to make our lifes easier :]
apt-get install bash curl git htop less nano postgresql psmisc redis-tools wget

# Set up NodeSource repository for Node.js 24.x
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -

# Install additional required packages (run/build dependencies)
apt-get install libclang-dev libmimalloc3 libvips-dev nodejs rustc zstd

# Environment-specific commands and packages
case $RAILS_ENV in
production | staging)
  ENVIRONMENT_PACKAGES="awscli"
  ;;
test)
  :
  ;;
*)
  ENVIRONMENT_PACKAGES="graphviz"
  ;;
esac
[[ -v ENVIRONMENT_PACKAGES ]] && apt-get install ${=ENVIRONMENT_PACKAGES}

# Clean up build context to reduce image size
rm -rf ./*(D)

exit 0
