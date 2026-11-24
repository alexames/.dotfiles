# Setup fzf
# ---------
# ~/.fzf is stowed from ~/.dotfiles/fzf/.fzf, a clone of junegunn/fzf whose
# binary install.sh downloads with `install --bin`.
if [[ -d "$HOME/.fzf/bin" && ":$PATH:" != *":$HOME/.fzf/bin:"* ]]; then
    PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# Key bindings (Ctrl-T, Ctrl-R, Alt-C) and completion.
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
