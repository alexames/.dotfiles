# Vim configuration

Part of the [.dotfiles](https://github.com/alexames/.dotfiles) repo, stowed to
`~/.vim`. Vim reads `~/.vim/vimrc` directly; put machine-specific settings in
`~/.vimrc` and have it start with `source ~/.vim/vimrc`.

## Installation

Run `./install.sh` from the root of the dotfiles repo. For vim it:

- builds vim from source with Python 3 and Lua support,
- installs the tools the config uses (see `apt.txt`, `cargo.txt` and
  `install_lua_ls` in `install.sh`): ripgrep, fzf, bat, universal-ctags,
  clang-format, shellcheck, yapf, cmake-format, stylua, luacheck and
  lua-language-server,
- stows this directory and installs the plugins with vim-plug, which includes
  building YouCompleteMe.

`./install.sh --skip-vim` skips all of the above.

Not automated:

- Debug adapters: run `:VimspectorInstall` inside vim.
- A [Nerd Font](https://www.nerdfonts.com/) in the terminal, for the airline
  and devicons glyphs.

## Layout

| File                     | Purpose                                         |
|--------------------------|-------------------------------------------------|
| `vimrc`                  | Plugins, options and plugin settings            |
| `keybinds.vim`           | All mappings, grouped by plugin                 |
| `vim-plug-bootstrap.vim` | Downloads vim-plug on first start if missing    |
| `global_extra_conf.py`   | YouCompleteMe Python interpreter settings       |

## Handy Cheat sheet

(TODO: Add list of neat utilities and features here)
