
$ESC = [char]27
$NEWLINE = '
'

# Text attributes
$ATTR_OFF = 0
$ATTR_BOLD = 1
$ATTR_UNDERSCORE = 4
$ATTR_BLINK
$ATTR_REVERSE_VIDEO = 7
$ATTR_CONCEALED = 8

# Foreground colors
$FORE_BLACK = 30
$FORE_RED = 31
$FORE_GREEN = 32
$FORE_YELLOW = 33
$FORE_BLUE = 34
$FORE_MAGENTA = 35
$FORE_CYAN = 36
$FORE_WHITE = 37

# Background colors
$BACK_BLACK = 40
$BACK_RED = 41
$BACK_GREEN = 42
$BACK_YELLOW = 43
$BACK_BLUE = 44
$BACK_MAGENTA = 45
$BACK_CYAN = 46
$BACK_WHITE = 47

function text-mode ($attr, $fore, $back) {
  $ESC.ToString() + '[' + $attr.ToString() + ';' + $fore.ToString() + ';' + $back.ToString() + 'm'
}

function find-ancestor-file ($filename, $dir) {
  # Walk up the directory hierarchy until the first file whose name
  # matches $fileName is found, and return that file's path.
  # If no such file is found, $file is (effectively) $null.
  $file =
    do {
      if (Test-Path -LiteralPath ($file = "$dir/$fileName")) {
        $file # output the path of the file found.
        break # exit the loop
      }
    } while ($dir = Split-Path -LiteralPath $dir)

  $file
}

function has-ancestor-file ($filename, $dir) {
  $(if (find-ancestor-file $filename $dir) {
    $true
  } else {
    $false
  })
}

function is-git-repo {
  has-ancestor-file '.git' $PWD.ProviderPath
}

function git-branch {
  $git_status = $(git status)
  $git_color = $(if (-not $($git_status -like "*working tree clean*")) {
    $(text-mode $ATTR_OFF $FORE_RED $BACK_BLACK)
  } elseif ($git_status -like "*Your branch is ahead of*") {
    $(text-mode $ATTR_OFF $FORE_YELLOW $BACK_BLACK)
  } elseif ($git_status -like "*nothing to commit*") {
    $(text-mode $ATTR_OFF $FORE_GREEN $BACK_BLACK)
  } else {
    $(text-mode $ATTR_OFF $FORE_BLACK $BACK_RED)
  })

  $on_branch = [regex]::match($git_status,'On branch ([^ \n\t]*)')
  $on_commit = [regex]::match($git_status,'HEAD detached at ([^ \n\t]*)')
  if ($on_branch) {
    $git_color + $on_branch.Groups[1].Value
  } elseif ($on_commit) {
    $git_color + $on_commit.Groups[1].Value
  }
}

function git-last-commit {
  $(git log -1 --pretty=format:'%s' --abbrev-commit)
}

function is-hg-repo {
  has-ancestor-file '.hg' $PWD.ProviderPath
}

function hg-branch {
  $(text-mode $ATTR_OFF $FORE_GREEN $BACK_BLACK) +
  $(hg branch)
}

function hg-last-commit {
  $(hg log -l1 --template '{desc|firstline}')
}

function vcs-prompt {
  $vcs = $null
  $vcs_branch = $null
  $vcs_last_commit = $null
  $(if (is-git-repo) {
    $vcs = 'git'
    $vcs_branch = $(git-branch)
    $vcs_last_commit = $(git-last-commit)
  } elseif (is-hg-repo) {
    $vcs = 'hg'
    $vcs_branch = $(hg-branch)
    $vcs_last_commit = $(hg-last-commit)
  } else {
    ''
  })

  $(if ($vcs) {
    $(text-mode $ATTR_OFF $FORE_WHITE $BACK_BLACK) +
    $vcs +
    ':' +
    $vcs_branch +
    $(text-mode $ATTR_OFF $FORE_WHITE $BACK_BLACK) +
    ':' +
    $(text-mode $ATTR_OFF $FORE_MAGENTA $BACK_BLACK) +
    $vcs_last_commit +
    $NEWLINE
  })
}

function prompt {
  $success = $?
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

  # This does't work for some reason. Unicode does not play well with the
  # prompt.
  # $(if ($success) {
  #   $(text-mode $ATTR_OFF $FORE_GREEN $BACK_BLACK) + '√' +
  # } else {
  #   $(text-mode $ATTR_OFF $FORE_RED $BACK_BLACK) + '✘' +
  # }) +
  # $NEWLINE +

  $NEWLINE +
  $(text-mode $ATTR_OFF $FORE_CYAN $BACK_BLACK) +
  $env:USERNAME +
  $(text-mode $ATTR_OFF $FORE_WHITE $BACK_BLACK) +
  '@' +
  $(text-mode $ATTR_OFF $FORE_CYAN $BACK_BLACK) +
  $env:COMPUTERNAME +
  $(text-mode $ATTR_OFF $FORE_WHITE $BACK_BLACK) +
  ':' +
  $(text-mode $ATTR_OFF $FORE_BLUE $BACK_BLACK) +
  $(Get-Location) +
  ' ' +
  $(text-mode $ATTR_OFF $FORE_YELLOW $BACK_BLACK) +
  '[' +
  $(Get-Date) +
  ']' +
  $NEWLINE +
  $(vcs-prompt) +
  $(text-mode $ATTR_OFF $FORE_RED $BACK_BLACK) +
  $(if (Test-Path variable:/PSDebugContext) { '[DBG] ' }
   elseif($principal.IsInRole($adminRole)) { '[ADMIN] ' }
   else { '' }
  ) +
  $(text-mode $ATTR_OFF $FORE_WHITE $BACK_BLACK) +
  $('> ' * ($nestedPromptLevel + 1))
}


