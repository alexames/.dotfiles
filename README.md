# Dotfiles

## Windows Powershell

Run `echo $PROFILE` to find the location of the PowerShell profile.

According to [this page][1] it should be located at 
`$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` in practice it
seems to vary a bit. The version of PowerShell that ships may also ask you to
install a different version of it as well, which has a profile in a different
location.

Open the profile file and add:

```
. "$HOME\.dotfiles\PowerShell_profile.ps1"
```

This may fail due to the default execution policy. To fix this, run:

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Bash

Run the following command to bootstrap `sudo` and `wget`, and then run the install script:

```
wget -q https://raw.githubusercontent.com/alexames/.dotfiles/main/install.sh && chmod +x install.sh && ./install.sh
```

Optionally add the NETWORK_INTERFACE to the .bashrc.local file.
```
# the network interface is optional, this allows bash to find your computer's
# name on the network.
NETWORK_INTERFACE=<network interface> 
```


[1](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3)
