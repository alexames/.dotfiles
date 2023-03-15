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
--------------------------------------------------------------------------------
# the network interface is optional, this allows bash to find your computer's
# name on the network.
NETWORK_INTERFACE=<network interface> 
. ~/.dotfiles/bashrc
```

Also download [fzf](https://github.com/junegunn/fzf/releases/latest) and [bat](https://github.com/sharkdp/bat/releases/latest), and [tmux-powerline](https://github.com/erikw/tmux-powerline/releases/latest) for some nice tmux related improvements.

### fzf setup
```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### tmux setup
```
$ cd
$ git clone https://github.com/gpakosz/.tmux.git
$ ln -s -f .tmux/.tmux.conf
$ cp .tmux/.tmux.conf.local .
```

Also follow instructions in .tmux/README.md

