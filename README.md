# Dotfiles

Personal configuration repo. Layout is one [GNU stow][stow] package per top-level
directory (`bash/`, `vim/`, `git/`, `starship/`, etc.) so any subset can be
linked into `$HOME` independently. `install.sh` handles package install, vim
build-from-source, third-party clones (fzf, oh-my-tmux), and runs `stow` over
everything.

## Setting up a machine with Claude Code

This README is the runbook. Point a Claude agent at this repo (or at
`https://github.com/alexames/.dotfiles`) and tell it to "install everything";
it should follow the steps below without further instructions.

**Order of work**

1. **Windows host** (if the machine runs Windows): follow [Windows](#windows)
   top to bottom. Do this before WSL — `install.sh` copies the Windows SSH keys
   into WSL, so they should exist first.
2. **WSL** (if `wsl -l -q` lists a distro), or **native Linux**: follow
   [Linux / WSL](#linux--wsl). From Windows, run commands in the distro with
   `wsl -e bash -lc '<command>'`. The WSL clone lives at `~/.dotfiles` inside
   the distro and is separate from the Windows clone.
3. **Verify** each platform with its checklist, then report back to the user
   what was installed, what was skipped, and the manual steps left over.

**Rules for the agent**

- Every step must be idempotent. Check the current state first (does the link
  exist and point at the right target? is the package installed?) and skip
  what is already done.
- Never overwrite or delete an existing file that differs from what the repo
  would put there. Move it to `~/.dotfiles-backup/<timestamp>/` (the same
  convention `install.sh` uses), or show the user the difference and ask.
- Ask before anything that needs elevation or user presence: installing WSL
  itself, `wsl --shutdown` (it kills every running WSL session), changing the
  execution policy beyond `CurrentUser`, or a step that needs a password.
  `sudo` inside WSL cannot be answered by the agent — if `sudo -n true` fails,
  ask the user to run `./install.sh -y` in a WSL terminal, then verify it.
- winget installers may raise a UAC prompt; tell the user to expect it.
- After winget installs, the agent's shell still has the old `PATH`. Refresh it
  before checking for the new tools:
  `$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')`
- Long steps (`install.sh` builds vim from source; YouCompleteMe compiles for
  several minutes) should run with a long timeout or in the background.
- Don't commit or push anything as part of setup. Machine-specific settings
  belong in the untracked override files (see
  [Per-machine overrides](#per-machine-overrides)), not in the repo.
- Do not try to run `gh auth login`; it is interactive. List it as a manual
  step instead.

## Linux / WSL

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/alexames/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` is idempotent — safe to re-run. If `~/.ssh/id_ed25519` doesn't
exist, the script first tries (on WSL) to copy the Windows user's keys from
`%USERPROFILE%\.ssh`; otherwise it generates a new key and prompts you to add
it to GitHub. From that point on, git's `insteadOf` rule rewrites GitHub URLs
to use SSH.

An agent should run it as `./install.sh -y`. Two things still need a person:
`sudo` (apt) may ask for a password, and if no SSH key exists anywhere the
script waits for a keypress after printing the new public key.

### Verify (Linux / WSL)

- `ls -l ~/.bashrc ~/.gitconfig ~/.vim ~/.claude/settings.json` — each is a
  symlink into `~/.dotfiles`.
- `vim -es -c 'qa!'` exits 0, and `vim +PlugStatus` shows no missing plugins.
- `command -v rg fzf delta stow starship` all resolve.
- `ls ~/.dotfiles-backup/` — mention any displaced files to the user.

Pre-existing files that would block stow (e.g. Ubuntu's default `~/.bashrc`)
are moved to `~/.dotfiles-backup/<timestamp>/` rather than overwritten.

### Flags

```
./install.sh -h               # full flag list
./install.sh --skip-apt       # skip the apt section
./install.sh --skip-cargo     # skip Rust/cargo packages
./install.sh --skip-luarocks  # skip lua packages
./install.sh --skip-vim       # skip the vim build, plugins and editor tooling
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

There is no stow on Windows, so the packages that matter there — `vim`, `git`,
`claude` and `powershell` — are wired up by hand. Directories are linked with
**junctions**, which need neither admin rights nor Developer Mode; single files
are replaced by a one-line file that includes or sources the repo copy. The
other packages (bash, zsh, tmux, inputrc, starship, fzf, gh, ripgrep) are
Linux-only.

### 1. Clone

```powershell
winget install --id Git.Git --exact
git clone https://github.com/alexames/.dotfiles.git "$HOME\.dotfiles"
```

Clone over HTTPS: the SSH rewrite only takes effect once the git config is
linked in step 3.

### 2. Tools

```powershell
$ids = @(
  'vim.vim'                      # Vim 9.2+, with +python3 and +terminal
  'Microsoft.PowerShell'         # pwsh, vim's 'shell'; Windows PowerShell 5.1 breaks plugins' 2>nul
  'Python.Python.3.13'           # YouCompleteMe and vim-claude-code's diff preview
  'Kitware.CMake'                # building YouCompleteMe
  'BurntSushi.ripgrep.MSVC'      # :Rg, :RgIn, 'grepprg'
  'junegunn.fzf'                 # fzf outside vim (git fzf aliases)
  'dandavison.delta'             # git pager
  'GitHub.cli'                   # gh
  'LLVM.LLVM'                    # clang-format for vim-codefmt, clangd
  'koalaman.shellcheck'          # ALE shell linting
  'JohnnyMorganz.StyLua'         # :FormatLua
  'UniversalCtags.Ctags'         # tagbar
  'DEVCOM.JetBrainsMonoNerdFont' # glyphs for vim-devicons and airline
)
foreach ($id in $ids) {
  winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
}
```

YouCompleteMe also needs the MSVC compiler. If `cl.exe` isn't available from
any Visual Studio install, add the Build Tools with the C++ workload (several
GB, raises a UAC prompt):

```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools --exact --override `
  "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

### 3. Link the configs

| Windows path            | Should be                                                            |
|-------------------------|----------------------------------------------------------------------|
| `~\.vim`                | junction → `~\.dotfiles\vim\.vim`                                     |
| `~\vimfiles`            | junction → `~\.vim` (the directory Windows Vim looks in)              |
| `~\.vimrc`              | file containing `source ~/.vim/vimrc`, plus any per-machine settings  |
| `~\.gitconfig`          | file containing only the include below                                |
| `~\.claude`             | junction → `~\.dotfiles\claude\.claude`                               |
| `$PROFILE`              | contains `. "$HOME\.dotfiles\powershell\powershell_profile.ps1"`      |

```powershell
New-Item -ItemType Junction -Path "$HOME\.vim"     -Target "$HOME\.dotfiles\vim\.vim"
New-Item -ItemType Junction -Path "$HOME\vimfiles" -Target "$HOME\.vim"
```

`~\.vimrc` — if neither `~\.vimrc` nor `~\_vimrc` exists, create it:

```vim
source ~/.vim/vimrc
if has('gui_running')
  set guifont=JetBrainsMono_NF:h11
endif
```

`~\.gitconfig` — don't copy the repo file (copies drift); include it instead.
Anything machine-specific goes in `~\.gitconfig.local`, which the repo config
already includes. If an existing `~\.gitconfig` has settings that aren't in the
repo, move them to `~\.gitconfig.local` (or ask) before replacing it.

```ini
[include]
	path = ~/.dotfiles/git/.gitconfig
```

`~\.claude` — Claude Code creates this directory on first run, so it usually
exists already, and a running Claude Code holds files open in it. Do this step
last, and if the move fails because files are in use, give the user the
commands to run after quitting Claude Code. Move the existing contents into
`~\.dotfiles\claude\.claude` without overwriting tracked files (the
credentials, history and project memories there are all gitignored), remove
the now-empty directory, then:

```powershell
New-Item -ItemType Junction -Path "$HOME\.claude" -Target "$HOME\.dotfiles\claude\.claude"
```

### 4. PowerShell profile

Use `$PROFILE` rather than a fixed path: it varies by PowerShell version and
moves under OneDrive when Documents is redirected ([docs][psprofile]). Create
the file if it doesn't exist, and append the line if it isn't already there:

```powershell
. "$HOME\.dotfiles\powershell\powershell_profile.ps1"
```

If `Get-ExecutionPolicy` reports `Restricted` or `AllSigned`, allow local
scripts:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 5. Windows Terminal font

Set the default font to the Nerd Font so vim shows icons instead of `?`. In
Windows Terminal's `settings.json` (Settings → Open JSON file), set
`profiles.defaults.font.face` to `"JetBrainsMono NF"` (the family name the
winget package installs). Profiles that set their own `font.face` override the
default, so update those too. Back up the file first; it is JSON with
comments, so edit it as text rather than round-tripping it through a JSON
parser.

### 6. Vim plugins

```powershell
vim -es -u "$HOME\vimfiles\vimrc" -i NONE -c "PlugInstall --sync" -c "qa!"
```

This also builds YouCompleteMe. If it was installed before CMake or MSVC were
available, rebuild it with `python install.py --clangd-completer` from
`~\vimfiles\plugged\YouCompleteMe`.

### Verify (Windows)

- `vim -es -c 'qa!'` exits 0, and `vim +PlugStatus` lists no missing plugins.
- `~\vimfiles\plugged\YouCompleteMe\third_party\ycmd\ycm_core*.pyd` exists.
- `git config --show-origin core.pager` reports `delta` from
  `.dotfiles/git/.gitconfig`.
- `Get-Command vim, pwsh, rg, fzf, delta, gh, clang-format, shellcheck, stylua, ctags`
  all resolve (after refreshing `PATH`).
- In a new Windows Terminal tab, `$env:COLORTERM` is `truecolor` (set by the
  profile) and vim's `:echo &termguicolors` prints `1`.

## WSL

The `wsl/.wslconfig` file lives at `%USERPROFILE%\.wslconfig` on the Windows
side, so stow can't link it from inside WSL. An agent should copy it from the
Windows clone (`$HOME\.dotfiles\wsl\.wslconfig`), asking first if a different
`.wslconfig` already exists, and ask before running `wsl --shutdown`. To keep
it linked instead, symlink it from PowerShell (run as administrator):

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
