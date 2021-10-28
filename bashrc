export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export COLOR_RESET='\e[0m' # No Color
export COLOR_BLACK='\e[0;30m'
export COLOR_GRAY='\e[1;30m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_WHITE='\e[1;37m'

function is_git_repo {
  echo "$(git rev-parse --is-inside-work-tree 2>/dev/null)"
}

function git_branch {
  local git_status="$(git status 2> /dev/null)"
  if [[ ! $git_status =~ "working tree clean" ]]; then
    git_color=$COLOR_RED
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    git_color=$COLOR_YELLOW
  elif [[ $git_status =~ "nothing to commit" ]]; then
    git_color=$COLOR_LIGHT_GREEN
  else
    git_color=$COLOR_BROWN
  fi

  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "${git_color}${branch}"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "${git_color}${commit}"
  fi
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
  echo -e "$(hg identify -b 2> /dev/null)"
}

function vcs_prompt {
  if [ "$(is_git_repo)" ]; then
    vcs="git"
    vcs_branch="$(git_branch)"
  elif [ "$(is_hg_repo)" ]; then
    vcs="hg"
    vcs_branch="$(hg_branch)"
  fi
  if [ "$vcs" ]; then
    echo "${COLOR_LIGHT_PURPLE}(${COLOR_WHITE}${vcs}:${vcs_color}${vcs_branch}${COLOR_LIGHT_PURPLE}) "
  fi
}

function ps1_update_prompt_command {

  if [ $? -eq 0 ]; then
    PS1="${COLOR_GREEN}√\n\n"
  else
    PS1="${COLOR_RED}✘\n\n"
  fi

  PS1+="${COLOR_LIGHT_CYAN}\u"       # Username
  PS1+="${COLOR_WHITE}@"             # @
  PS1+="${COLOR_LIGHT_CYAN}\H"       # Hostname
  PS1+="${COLOR_WHITE}:"             # :
  PS1+="${COLOR_LIGHT_BLUE}\$PWD "   # Working directory
  PS1+="$(vcs_prompt)"               # Git/Hg branch
  PS1+="${COLOR_YELLOW}[\$(date +\"%y/%m/%d %H:%M:%S\")]\n"
                                     # Current date and time
  PS1+="${COLOR_RESET}\$ "           # Prompt
  export PS1
}

PROMPT_COMMAND=ps1_update_prompt_command

