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

Run the following command:
```
wget -q https://raw.githubusercontent.com/alexames/.dotfiles/main/install.sh && chmod +x install.sh && ./install.sh
```

Optionally add the NETWORK_INTERFACE to the .bashrc file.
```
# the network interface is optional, this allows bash to find your computer's
# name on the network.
NETWORK_INTERFACE=<network interface> 
. ~/.dotfiles/bashrc
```


