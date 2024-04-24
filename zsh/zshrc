################################################################################
# https://stackoverflow.com/a/1128583


setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s:%F{2}%b%F{3}|%F{1}%a%F{5})%f '
zstyle ':vcs_info:*' formats '%F{5}(%f%s:%F{2}%b%F{5})%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git cvs svn hg
zstyle ':vcs_info:hg*:*' check-for-changes true

function vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "${vcs_info_msg_0_}"
  fi
}

################################################################################

#load colors
autoload colors && colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    #wrap colours between %{ %} to avoid weird gaps in autocomplete
    eval $COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
    eval BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
eval RESET='%{$reset_color%}'
NEWLINE=$'\n'

################################################################################

PROMPT_USERNAME_PATH="${BOLD_CYAN}%n${BOLD_WHITE}@${BOLD_CYAN}%m${BOLD_WHITE}:${BOLD_BLUE}%d"
PROMPT_DATETIME="%{$fg[yellow]%}[%D{%f/%m/%y} %D{%H:%M:%S}] "
PROMPT_STATUSCHECK='%(?.%F{green}√.%F{red}✘) '
PROMPT_VCS_STATUS=$'$(vcs_info_wrapper)'
PROMPT_SCREEN_NAME=$'$(screen_name_wrapper)'

function screen_name_wrapper() {
  local terminal_type=
  local terminal_name=
  if { [ "$TERM" = "screen" ]; } then
    terminal_type='screen'
    terminal_name=$STY
  elif { [ -n "${TMUX}" ]; } then
    terminal_type='tmux'
    terminal_name='$(tmux display-message -p '#S')'
  fi
  if { [ -n "${terminal_type}" ]; } then
    echo "${BOLD_MAGENTA}(${BOLD_WHITE}${terminal_type}:${BOLD_GREEN}${terminal_name}${BOLD_MAGENTA}) "
  fi
}

PROMPT=""
PROMPT+="${PROMPT_STATUSCHECK}${NEWLINE}"
PROMPT+="${NEWLINE}"
PROMPT+="${BOLD_CYAN}%n"
PROMPT+="${BOLD_WHITE}@"
PROMPT+="${BOLD_CYAN}%m"
PROMPT+="${BOLD_WHITE}:"
PROMPT+="${BOLD_BLUE}%d"
PROMPT+=" "
PROMPT+="${PROMPT_VCS_STATUS}"
PROMPT+="${PROMPT_SCREEN_NAME}"
PROMPT+="${PROMPT_DATETIME}"
PROMPT+="${NEWLINE}${RESET}%# "
export PROMPT

