# Dotfiles

Personal configuration repo. Layout is one [GNU stow][stow] package per top-level
directory (`bash/`, `vim/`, `git/`, `starship/`, etc.) so any subset can be
linked into `$HOME` independently. `install.sh` handles package install, vim
build-from-source, third-party clones (fzf, oh-my-tmux), and runs `stow` over
everything.

## Linux / WSL

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/alexames/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` is idempotent — safe to re-run. The script is what actually
generates an SSH key and prompts you to add it to GitHub; from that point on,
git's `insteadOf` rule rewrites GitHub URLs to use SSH.

### Flags

```
./install.sh -h               # full flag list
./install.sh --skip-apt       # skip the apt section
./install.sh --skip-cargo     # skip Rust/cargo packages
./install.sh --skip-luarocks  # skip lua packages
./install.sh --skip-vim       # skip the vim-from-source build
./install.sh --skip-stow      # skip the final stow step
./install.sh -y               # answer "yes" to prompts (e.g. starship install)
```

### Post-install

A few things `install.sh` can't safely automate:

- **starship** — add `eval "$(starship init bash)"` to `~/.bashrc.local`
- **gh** — run `gh auth login` to authenticate the GitHub CLI
- **WSL** — symlink `.wslconfig` to `%USERPROFILE%` (see [WSL](#wsl) below)

## Per-machine overrides

Anything machine-specific or secret belongs in files that aren't checked in.
These are sourced automatically when they exist:

| File                  | Purpose                                       |
|-----------------------|-----------------------------------------------|
| `~/.bashrc.local`     | Per-host env vars, API keys, host-only PATH   |
| `~/.gitconfig.local`  | Work email/signing key, per-host git config   |

Example `~/.bashrc.local`:

```bash
# Network interface used by the prompt to find this machine's name.
NETWORK_INTERFACE=enp4s0

# Secrets stay out of the repo.
export PORTKEY_API_KEY=...

# Enable starship if installed.
command -v starship >/dev/null && eval "$(starship init bash)"
```

Example `~/.gitconfig.local`:

```ini
[user]
    email = alex@work.example.com
    signingkey = ABC123...
[commit]
    gpgsign = true
```

## Stow packages

The installer runs `stow -R` over every top-level directory. Each package can
also be stowed individually:

```bash
cd ~/.dotfiles
stow -t ~ bash git vim   # link these three only
stow -t ~ -D claude      # remove the claude package's symlinks
```

| Package        | What it provides                                                   |
|----------------|--------------------------------------------------------------------|
| `bash`         | `.bashrc`, `.profile`, aliases, prompt helpers                     |
| `zsh`          | `.zshrc`                                                           |
| `git`          | `.gitconfig` with delta, fzf aliases, custom log formats           |
| `vim`          | `.vim/` runtime + `vimrc`                                          |
| `tmux`         | oh-my-tmux config (`.tmux.conf` + `.tmux.conf.local`)              |
| `fzf`          | `.fzf.bash` integration                                            |
| `inputrc`      | Readline completion + Up/Down history-search                       |
| `starship`     | `~/.config/starship.toml` prompt config                            |
| `gh`           | GitHub CLI config (delta pager, ssh protocol, aliases)             |
| `ripgrep`      | `~/.ripgreprc` (smart-case, hidden, ignores)                       |
| `editorconfig` | Global `~/.editorconfig` defaults                                  |
| `claude`       | Claude Code settings (`~/.claude/settings.json`)                   |
| `wsl`          | `.wslconfig` template — see [WSL](#wsl)                            |
| `powershell`   | Windows PowerShell profile — see [Windows](#windows)               |

## Windows

Install supporting tools via winget:

```powershell
winget install --id Nerd-Fonts.FiraCode
winget install --id dandavison.delta
```

- **FiraCode Nerd Font** — required for file-type glyphs in Vim (NERDTree via
  `vim-devicons`) and powerline separators in `vim-airline`. After installing,
  set the font in Windows Terminal (Settings → profile → Appearance → Font
  face) and gvim (`set guifont=FiraCode\ Nerd\ Font:h11`). Without a Nerd Font
  you'll see `?` in place of icons.
- **delta** — referenced by the git config as the pager for `diff`/`log`/`show`.

### PowerShell profile

Run `echo $PROFILE` to find your profile path. According to [the docs][psprofile]
it should live at `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`,
but in practice it varies by PowerShell version.

Open the profile file and add:

```powershell
. "$HOME\.dotfiles\powershell\powershell_profile.ps1"
```

If this fails due to the execution policy, allow signed local scripts:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## WSL

The `wsl/.wslconfig` file lives at `%USERPROFILE%\.wslconfig` on the Windows
side, so stow can't link it from inside WSL. Either symlink it manually from
PowerShell (run as administrator):

```powershell
New-Item -ItemType SymbolicLink `
    -Path   "$env:USERPROFILE\.wslconfig" `
    -Target "\\wsl$\Ubuntu\home\$env:UserName\.dotfiles\wsl\.wslconfig"
```

…or just copy it. Either way, run `wsl --shutdown` to apply changes.

## See also

- [`cheatsheet.md`](cheatsheet.md) — quick reference for the keybinds, aliases,
  and tmux/vim shortcuts configured here.

[stow]: https://www.gnu.org/software/stow/
[psprofile]: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
