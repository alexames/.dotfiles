#!/bin/bash

sudo add-apt-repository -y universe
sudo add-apt-repository -y multiverse
sudo apt update
sudo apt install -y ssh

################################################################################
# Create ssh key if necessary.

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

package_pattern='^ *([^# ]+)'

apt_list="apt.txt"
sudo apt install -y --no-install-recommends \
    $(grep -oE "$package_pattern" "$apt_list" | xargs)

################################################################################
# Install Rust and Rust packages
if ! command -v rustc &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs      | sh
fi

cargo_list="cargo.txt"
cargo install \
    $(grep -oE "$package_pattern" "$cargo_list" | xargs)

################################################################################
# Install Lua packages
luarocks_list="luarocks.txt"
failures=""
grep -oE "$package_pattern" "$luarocks_list" | while read -r rock; do
    echo -n "Installing $rock... "
    for version in 5.1 5.2 5.3 5.4; do
        if luarocks --lua-version="$version" --local \
                    install "$rock" > /dev/null 2>&1; then
            echo -n "$version, "
        else
            failures+="Failed to build $rock for Lua $version\n"
        fi
    done
    echo
done
echo $failures >&2

################################################################################
# Install .dotfiles git repo and initialize.

function _git_clone_or_pull() {
    if [ -d "$2" ]; then
        git -C "$2" pull
    else
        git clone "$1" "$2"
    fi
}

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

