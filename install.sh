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
sudo apt install                                             \
    # Utilities                                              \
    bat                                                      \
    curl                                                     \
    fzf                                                      \
    net-tools                                                \
    silversearcher-ag                                        \
    stow                                                     \
    tmux                                                     \
    vim                                                      \
    wget                                                     \
    # Development tools                                      \
    cmake                                                    \
    git                                                      \
    # Languages                                              \
    clang                                                    \
    lua5.4                                                   \
    python3                                                  \
    python3-pip                                              \
    python-is-python3                                        \
    # Dependencies for the YouCompleteMe vim plugin.         \
    # https://github.com/ycm-core/YouCompleteMe#linux-64-bit \
    build-essential                                          \
    cmake                                                    \
    golang                                                   \
    mono-complete                                            \
    nodejs                                                   \
    npm                                                      \
    openjdk-17-jdk                                           \
    openjdk-17-jre                                           \
    python3-dev                                              \
    vim-nox

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
git clone https://github.com/alexames/.dotfiles ~/.dotfiles
cd ~/.dotfiles
stow bash fzf git tmux vim

# Install Vim plugins.
# https://stackoverflow.com/a/12834450/63791
vim +PluginInstall +qall

