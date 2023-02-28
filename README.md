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
