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

sudo apt install -y                                          \
    bat                                                      \
    curl                                                     \
    fzf                                                      \
    net-tools                                                \
    silversearcher-ag                                        \
    stow                                                     \
    tmux                                                     \
    vim                                                      \
    wget                                                     \
    cmake                                                    \
    git                                                      \
    clang                                                    \
    lua5.4                                                   \
    python3                                                  \
    python3-pip                                              \
    python-is-python3                                        \
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

################################################################################
# Install pip packages

python -m ensurepip --upgrade
pip install  \
    yapf \
    cmakelang

################################################################################
# Install rust (Can this be moved to under apt?)

# if ! command -v rustc &> /dev/null; then
#   # When using WSL, rust prefers a different installation method.
#   # https://stackoverflow.com/a/38859331/63791
#   if grep -qi microsoft /proc/version; then
#     curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs      | sh
#   else
#     curl                                 https://sh.rustup.rs -sSf | sh
#   fi
# fi

################################################################################
# Install .dotfiles git repo and initialize.

function _git_clone_or_pull() {
    if [ -d "$2" ]; then
        echo "pulling"
        git -C "$2" pull
    else
        echo "cloning"
        git clone "$1" "$2"
    fi
}

_git_clone_or_pull https://github.com/alexames/.dotfiles ~/.dotfiles
_git_clone_or_pull https://github.com/junegunn/fzf ~/.dotfiles/fzf/.fzf
_git_clone_or_pull https://github.com/gpakosz/.tmux ~/.dotfiles/tmux/.tmux

echo "You can now run stow on the following package configs"
echo
echo $(find ~/.dotfiles/* -maxdepth 0 -type d | xargs -n1 basename | tr "\n" "\t")
echo

