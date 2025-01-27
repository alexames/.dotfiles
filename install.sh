#!/bin/bash

################################################################################
# Create ssh key if necessary.

sudo apt update
sudo apt install -y ssh

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
  echo "Setting up ssh key"
  ssh-keygen -t ed25519 -C 'Alexander.Ames@gmail.com' -q -N ""
  ssh-add ~/.ssh/id_ed25519
  cat ~/.ssh/id_ed25519.pub
  echo "Open https://github.com/settings/ssh/new and add new key"
  echo "(Press any key when done)"
  read -n 1 -s
fi

################################################################################
# Install apt packages

################################################################################
# General utilities
sudo apt install -y                                                            \
    bat                                                                        \
    curl                                                                       \
    net-tools                                                                  \
    silversearcher-ag                                                          \
    stow                                                                       \
    tmux                                                                       \
    fd-find                                                                    \
    wget

################################################################################
# Git
sudo apt install -y                                                            \
    make                                                                       \
    git                                                                        \
    git-delta

################################################################################
# C++
sudo apt install -y                                                            \
    clang                                                                      \
    cmake                                                                      \
    valgrind                                                                   \
    rr                                                                         \
    build-essential

################################################################################
# Lua
sudo apt install -y                                                            \
    lua5.1                                                                     \
    lua5.1-dev                                                                 \
    lua5.2                                                                     \
    lua5.2-dev                                                                 \
    lua5.3                                                                     \
    lua5.3-dev                                                                 \
    lua5.4                                                                     \
    lua5.4-dev

################################################################################
# Python
sudo apt install -y                                                            \
    python3                                                                    \
    python3-pip                                                                \
    python-is-python3                                                          \
    python3-dev                                                                \
    libpython3-dev
python -m ensurepip --upgrade
pip install                                                                    \
    yapf                                                                       \
    cmakelang

################################################################################
# Go
sudo apt install -y                                                            \
    golang

################################################################################
# C#
sudo apt install -y                                                            \
    mono-complete

################################################################################
# Javascript
sudo apt install -y                                                            \
    nodejs                                                                     \
    npm

################################################################################
# Java
sudo apt install -y                                                            \
    openjdk-17-jdk                                                             \
    openjdk-17-jre

################################################################################
# Rust
if ! command -v rustc &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs      | sh
fi

################################################################################
# Install .dotfiles git repo and initialize.

function _git_clone_or_pull() {
    if [ -d "$2" ]; then
        git -C "$2" pull
    else
        git clone "$1" "$2"
    fi
}

_git_clone_or_pull https://github.com/alexames/.dotfiles ~/.dotfiles

# Install fzf.
_git_clone_or_pull https://github.com/junegunn/fzf ~/.dotfiles/fzf/.fzf
~/.dotfiles/fzf/.fzf/install

# Install Oh my tmux config.
_git_clone_or_pull https://github.com/gpakosz/.tmux ~/.dotfiles/tmux/.tmux

# Install vim from source.
_git_clone_or_pull https://github.com/vim/vim ~/.dotfiles/vim/.vim/src/vim
cd ~/.dotfiles/vim/.vim/src/vim
./configure                 \
    --with-features=huge    \
    --enable-python3interp  \
    --enable-luainterp      \
    --enable-cscope
sudo make
sudo make install

echo "You can now run stow on the following package configs"
echo
echo $(find ~/.dotfiles/* -maxdepth 0 -type d | xargs -n1 basename | tr "\n" "\t")
echo

