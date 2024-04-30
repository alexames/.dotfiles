# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Ensure that the dot files and vimrc are always up to date.
git -C ~/.dotfiles pull > /dev/null

export EDITOR='vim'
export VISUAL='vim'

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Also use bashrc if it exists.
if [ -n "$BASH" ] ; then
   source ~/.bashrc
fi
[ -r ~/.profile.local ] && source ~/.profile.local

# pip configuration.
eval "$(pip completion --bash)"

# pipenv configuration.
export PIPENV_VENV_IN_PROJECT=true

echo 'Active tmux sessions (hint: use tnas to attach)'
tmux ls
