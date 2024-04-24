# Ensure that the dot files and vimrc are always up to date.
git -C ~/.dotfiles pull > /dev/null
git -C ~/.vim      pull > /dev/null

export EDITOR='vim'
export VISUAL='vim'

echo 'Active tmux sessions (hint: use tnas to attach)'
tmux ls
