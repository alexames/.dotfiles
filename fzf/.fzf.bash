# Setup fzf
# ---------
if [[ ! "$PATH" == */home/alex/.fzf/bin* ]]; then
  PATH="/home/alex/.fzf/bin:${PATH:+${PATH}}"
fi

eval "$(fzf --bash)"
