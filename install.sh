#!/bin/bash

read -p 'name: ' name
read -p 'email: ' email

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  echo "Setting up ssh key"
  ssh-keygen -t ed25519 -C $email
  ssh-add ~/.ssh/id_ed25519
  cat ~/.ssh/id_ed25519.pub
  echo "Open https://github.com/settings/ssh/new and add new key"
  echo "(Press any key when done)"
fi

# Ensure the basics are installed.
sudo apt update
sudo apt install      \
    cmake             \
    curl              \
    git               \
    lua               \
    python3           \
    python-is-python3 \
    tmux              \
    vim

# Install python-based formatting tools.
python -m ensurepip --upgrade
pip install  \
    yapf \
    cmakelang

# Install rust.
# When using WSL, rust prefers a different installation method, so check for WSL
# https://stackoverflow.com/a/38859331/63791
if grep -qi microsoft /proc/version; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs      | sh
else
  curl                                 https://sh.rustup.rs -sSf | sh
fi

# Clone down my config files as well as various utilities. Installation and
# configuration to follow below.
## Configs
git clone             https://github.com/alexames/.dotfiles ~/.dotfiles
git clone --recursive https://github.com/alexames/.vim      ~/.vim
git clone             https://github.com/gpakosz/.tmux      ~/.tmux
## Utilities
git clone --depth 1   https://github.com/junegunn/fzf       ~/.fzf
git clone             https://github.com/sharkdp/bat        ~/.bat

# A utility function that I stole from fzf to safely append lines to a file.
# https://github.com/junegunn/fzf/blob/e5103d94290eb9d65807a9f1ecee673bd9ce7cc2/install#L298
# MIT licensed
# https://github.com/junegunn/fzf/blob/e5103d94290eb9d65807a9f1ecee673bd9ce7cc2/LICENSE
append_line() {
  set -e

  local update line file pat lno
  line="$1"
  file="$2"
  lno=""

  echo "Update $file:"
  echo "  - $line"
  if [ -f "$file" ]; then
    lno=$(\grep -nF "$line" "$file" | sed 's/:.*//' | tr '\n' ' ')
  fi
  if [ -n "$lno" ]; then
    echo "    - Already exists: line #$lno"
  else
    [ -f "$file" ] && echo >> "$file"
    echo "$line" >> "$file"
    echo "    + Added"
  fi
  echo
  set +e
}

# Ensure that the dot files and vimrc are always up to date.
append_line 'git -C ~/.dotfiles pull > /dev/null' ~/.bashrc
append_line 'git -C ~/.vim      pull > /dev/null' ~/.bashrc
append_line 'source ~/.dotfiles/bashrc' ~/.bashrc

# Set up my vimrc file to point at the downloaded vimrc.
append_line 'source ~/.dotfiles/bashrc' ~/.bashrc
echo 'so ~/.vim/vimrc' > ~/.vimrc

# Set up git config.
git config --global user.email $email
git config --global user.name $name
git config --global include.path "~/.dotfiles/gitconfig"

# Set up the tmux config.
ln -s -f .tmux/.tmux.conf
ln -s -f .dotfiles/.tmux.conf.local

# Dependencies for the YouCompleteMe vim plugin.
# https://github.com/ycm-core/YouCompleteMe#linux-64-bit
sudo apt install    \
    build-essential \
    cmake           \
    vim-nox         \
    python3-dev     \
    mono-complete   \
    golang          \
    nodejs          \
    openjdk-17-jdk  \
    openjdk-17-jre  \
    npm

# Install the most up to date fzf.
yes | ~/.fzf/install

# Install the Silver Searcher, useful in general and works well with fzf.vim.
sudo apt silversearcher-ag

# Install bat
cargo install --locked .bat

# Install Vim plugins.
# https://stackoverflow.com/a/12834450/63791
vim +PluginInstall +qall
