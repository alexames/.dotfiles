# Make tmux play nicely with bash history
# https://askubuntu.com/a/339925/24501
# avoid duplicates.
export HISTCONTROL=ignoredups:erasedups

# append history entries.
shopt -s histappend

# After each command, save and reload history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export COLOR_RESET='\[\e[0m\]' # No Color
export COLOR_BLACK='\[\e[0;30m\]'
export COLOR_GRAY='\[\e[1;30m\]'
export COLOR_RED='\[\e[0;31m\]'
export COLOR_LIGHT_RED='\[\e[1;31m\]'
export COLOR_GREEN='\[\e[0;32m\]'
export COLOR_LIGHT_GREEN='\[\e[1;32m\]'
export COLOR_BROWN='\[\e[0;33m\]'
export COLOR_YELLOW='\[\e[1;33m\]'
export COLOR_BLUE='\[\e[0;34m\]'
export COLOR_LIGHT_BLUE='\[\e[1;34m\]'
export COLOR_PURPLE='\[\e[0;35m\]'
export COLOR_LIGHT_PURPLE='\[\e[1;35m\]'
export COLOR_CYAN='\[\e[0;36m\]'
export COLOR_LIGHT_CYAN='\[\e[1;36m\]'
export COLOR_LIGHT_GRAY='\[\e[0;37m\]'
export COLOR_WHITE='\[\e[1;37m\]'

function timer_now {
  date +%s%N
}

function timer_start {
  timer_start=${timer_start:-$(timer_now)}
}

function timer_stop {
  local delta_us=$((($(timer_now) - $timer_start) / 1000))
  local us=$((delta_us % 1000))
  local ms=$(((delta_us / 1000) % 1000))
  local s=$(((delta_us / 1000000) % 60))
  local m=$(((delta_us / 60000000) % 60))
  local h=$((delta_us / 3600000000))
  # Goal: always show around 3 digits of accuracy
  if ((h > 0)); then timer_show=${h}h${m}m
  elif ((m > 0)); then timer_show=${m}m${s}s
  elif ((s >= 10)); then timer_show=${s}.$((ms / 100))s
  elif ((s > 0)); then timer_show=${s}.$(printf %03d $ms)s
  elif ((ms >= 100)); then timer_show=${ms}ms
  elif ((ms > 0)); then timer_show=${ms}.$((us / 100))ms
  else timer_show=${us}us
  fi
  timer_show="elapsed:${timer_show}"
  unset timer_start
}

function is_git_repo {
  echo "$(git rev-parse --is-inside-work-tree 2>/dev/null)"
}

function git_branch {
  local git_status="$(git status 2> /dev/null)"
  if [[ ! $git_status =~ "working tree clean" ]]; then
    git_color=$COLOR_LIGHT_RED
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    git_color=$COLOR_YELLOW
  elif [[ $git_status =~ "nothing to commit" ]]; then
    git_color=$COLOR_LIGHT_GREEN
  else
    git_color=$COLOR_BROWN
  fi

  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"
  local sha="$(git rev-parse --short HEAD 2>/dev/null)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    if [[ -n "$sha" ]]; then
      echo "${git_color}${branch}${COLOR_WHITE}:${COLOR_LIGHT_BLUE}${sha}"
    else
      echo "${git_color}${branch}${COLOR_WHITE}:${COLOR_LIGHT_PURPLE}<no commits>"
    fi
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "${git_color}${commit}${COLOR_WHITE}:${COLOR_LIGHT_BLUE}${sha}"
  fi
}

function git_last_commit {
  echo "$(git log -1 --pretty=format:'%s' --abbrev-commit 2>/dev/null | sed 's/\\/\\\\/g')"
}

function is_hg_repo() {
  local root="$(pwd -P)"
  while [[ $root && ! -d $root/.hg ]]
  do
    root="${root%/*}"
  done
  echo "$root"
}

function hg_branch {
  echo -e "$COLOR_LIGHT_GREEN$(hg identify -b 2> /dev/null)"
}

function hg_last_commit {
  echo "$(hg log -l1 --template '{desc|firstline}' | sed 's/\\/\\\\/g')"
}

function vcs_prompt {
  if [ "$(is_git_repo)" ]; then
    vcs="git"
    vcs_branch="$(git_branch)"
    vcs_last_commit="$(git_last_commit)"
  elif [ "$(is_hg_repo)" ]; then
    vcs="hg"
    vcs_branch="$(hg_branch)"
    vcs_last_commit="$(hg_last_commit)"
  fi
  if [ "$vcs" ]; then
    if [[ -n "$vcs_last_commit" ]]; then
      echo "${COLOR_WHITE}[${vcs}${COLOR_WHITE}:${vcs_branch}${COLOR_WHITE}:${COLOR_LIGHT_PURPLE}${vcs_last_commit}${COLOR_WHITE}]\n"
    else
      echo "${COLOR_WHITE}[${vcs}${COLOR_WHITE}:${vcs_branch}${COLOR_WHITE}]\n"
    fi
  else
    echo ""
  fi
}

function venv_prompt {
  if [[ "$VIRTUAL_ENV" != "" ]]
  then
    VENV_RELPATH=$(realpath --relative-to="." "$VIRTUAL_ENV")
    echo "[venv:${VENV_RELPATH}] "
  fi
}

function tmux_prompt {
  if [ -n "$TMUX" ]; then
    echo "[tmux:$(tmux display-message -p "#S")] "
  else
    echo ""
  fi
}


# if [ ! -z ${NETWORK_INTERFACE+x} ]; then
#   ALEX_LOCAL_IP=$(echo $(ifconfig enp4s0 2>/dev/null) $(ifconfig eth0 2>/dev/null) | grep -o 'inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | cut -c 6-)
#   ALEX_HOSTNAME=$(nslookup $ALEX_LOCAL_IP | grep -o '= [a-zA-Z0-9_-]\+\(\.[a-zA-Z0-9_-]\+\)*' | cut -c 3-)
# else
ALEX_HOSTNAME="\H"
# fi

function host_or_nameserver_name {
  echo $ALEX_HOSTNAME
}

function ps1_update_prompt_command {
  exit_code=$?
  PS1=""
  if [ $exit_code -eq 0 ]
  then
    PS1+="${COLOR_GREEN}√ "
  else
    PS1+="${COLOR_RED}✘ "
  fi
  PS1+="${COLOR_WHITE}[status:$exit_code] "
  timer_stop
  PS1+="${COLOR_YELLOW}[$timer_show]\n\n"

  PS1+="${COLOR_LIGHT_CYAN}\u"       # Username
  PS1+="${COLOR_WHITE}@"             # @
  PS1+="${COLOR_LIGHT_CYAN}$(host_or_nameserver_name)"       # Hostname
  PS1+="${COLOR_WHITE}:"             # :
  PS1+="${COLOR_LIGHT_BLUE}\$PWD "   # Working directory
  PS1+="${COLOR_CYAN}$(tmux_prompt)" # Virtual environment
  PS1+="${COLOR_LIGHT_GREEN}$(venv_prompt)" # Virtual environment

  # This seems to be broken on Windows Git Bash...
  # PS1+="${COLOR_YELLOW}[\$(date +\"%y/%m/%d %H:%M:%S\")]\n"
  # ...but this next line works fine.
  PS1+="${COLOR_YELLOW}[$(date +'%y/%m/%d %H:%M:%S')]"
                                     # Current date and time
  PS1+='\n'
  PS1+="$(vcs_prompt)"               # Git/Hg branch
  PS1+="${COLOR_RESET}\$ "           # Prompt
  export PS1
}

trap 'timer_start' DEBUG
PROMPT_COMMAND=ps1_update_prompt_command

fd() {
  preview="git diff $@ --color=always -- {-1}"
  git diff $@ --name-only | fzf -m --ansi --preview $preview
}

