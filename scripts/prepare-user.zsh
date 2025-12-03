#!/usr/bin/env -S zsh --login
set -xeuo pipefail

## Environment prerequisites
if [[ -z ${GROUP-} || -z ${GROUP_ID-} ]]; then
    printf 'GROUP and GROUP_ID must be set and non-empty\n' >&2
    exit 101
fi
if [[ -z ${USER-} || -z ${USER_ID-} ]]; then
    printf 'USER and USER_ID must be set and non-empty\n' >&2
    exit 102
fi
export HOME=/home/$USER
LD_PRELOAD=${LD_PRELOAD-}
SYSTEM_GROUP=$( { getent group "${GROUP_ID}" | cut -d: -f1 || true; } )
SYSTEM_USER=$( { getent passwd "${USER_ID}" | cut -d: -f1 || true; } )

# Create or modify system group and user to match specified IDs
[[ -z $SYSTEM_GROUP ]] && addgroup --gid $GROUP_ID $GROUP || groupmod -n $GROUP -g $GROUP_ID $SYSTEM_GROUP
if [[ -z $SYSTEM_USER ]]; then
  adduser --uid $USER_ID --ingroup $GROUP --home $HOME --shell $(which zsh) --disabled-password $USER
else
  usermod -l $USER -u $USER_ID -g $GROUP -d $HOME -s $(which zsh) -c "$USER" $SYSTEM_USER
fi

# Set up home directory
mkdir -p $HOME
chmod -R 700 $HOME
chown -R $USER:$GROUP $HOME

# Set environment variables and preferences for the new user
PRELOAD=$(echo "$LD_PRELOAD $(find /usr/lib -name 'libmimalloc.so*' | head -n 1)" | xargs)
echo export CFLAGS=\"-O3 -pipe\" >>$HOME/.zshenv
echo export CXXFLAGS=\"-O3 -pipe\" >>$HOME/.zshenv
echo export EDITOR=\"nano\" >>$HOME/.zshenv
echo export LD_PRELOAD=\"$PRELOAD\" >>$HOME/.zshenv
echo typeset -U path >>$HOME/.zlogin

# Install and configure nano
echo 'include /usr/share/nano/*.nanorc' >>$HOME/.nanorc
echo 'include /usr/share/nano/extra/*.nanorc' >>$HOME/.nanorc
chown -R $USER:$GROUP $HOME
su $USER -c "curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | zsh"

# Install and configure Oh My Zsh
chmod a+rx ohmyzsh.sh && su $USER -c "zsh -cel ./ohmyzsh.sh"

# Reclaim ownership of home directory
chown -R $USER:$GROUP $HOME

# Clean up build context to reduce image size
rm -rf ./*(D)

exit 0
