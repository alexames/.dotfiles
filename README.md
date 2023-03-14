# Dotfiles

## Windows Powershell

Look for the file 
`$Home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` or 
`$Home\Documents\Powershell\Microsoft.PowerShell_profile.ps1`

And add:

```
. "$HOME\.dotfiles\PowerShell_profile.ps1"
```

## Bash

Add the following to `~/.bashrc`

```
NETWORK_INTERFACE=<network interface> # optional
. ~/.dotfiles/bashrc
```

Also download [fzf](1) and [bat](2)

[1][https://github.com/junegunn/fzf/releases/latest]
[2][https://github.com/sharkdp/bat/releases/latest]

```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

