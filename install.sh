#!/bin/bash

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  echo "Setting up ssh key"
  ssh-keygen -t ed25519 -C 'Alexander.Ames@gmail.com'
  ssh-add ~/.ssh/id_ed25519
  cat ~/.ssh/id_ed25519.pub
  echo "Open https://github.com/settings/ssh/new and add new key"
  echo "(Press any key when done)"
fi

# Ensure the basics are installed.
sudo apt update
sudo apt install      \
    cmake             \
    bat               \
    curl              \
    fzf               \
    git               \
    lua5.4            \
    net-tools         \
    python3           \
    python3-pip       \
    python-is-python3 \
    silversearcher-ag \
    stow              \
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

# Clone down my config files as well as various utilities. Installation and
# configuration to follow below.
git clone https://github.com/alexames/.dotfiles ~/.dotfiles
cd ~/.dotfiles
stow bash git tmux vim

# Install Vim plugins.
# https://stackoverflow.com/a/12834450/63791
vim +PluginInstall +qall

