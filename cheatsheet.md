
## bash

## fzf

## git

| Diffing                             | Command       |
|:------------------------------------|:--------------|
| diff                                | `d`           |
| difftool                            | `dt `         |
| mergetool                           | `mt `         |
| **Staging**                         |               |
| add file                            | `a`           |
| add all                             | `aa `         |
| **Committing**                      |               |
| commit                              | `c`           |
| commit all                          | `ca `         |
| commit with message                 | `cm `         |
| commit all with message             | `cam`         |
| amend                               | `amend`       |
| amend without updating message      | `m`           |
| ammend all without updating message | `ma `         |
| **Tracking**                        |               |
| track branch                        | `track`       |
| track branch                        | `t`           |
| **Logs**                            |               |
| simple linear log                   | `l`           |
| simple linear log with all branches | `la `         |
| log with graph                      | `lg `         |
| simple log                          | `simple-log ` |
| **fzf commands**                    |               |
| push to branch                      | `p`           |
| checkout branch                     | `b`           |
| checkout ref                        | `co `         |
| rebase against                      | `rb `         |

## powershell

## tmux

https://tmuxcheatsheet.com/

| Action             | Binding <C-b> | Command             | Abbr  |
| :----------------- | :------------ | :------------------ | :---- |
| New Session        |               | `:new`              |       |
| Kill Session       |               | `:kill-session`     | `:bd` |
| List Sessions      | `p`           | `:list-sessions`    | `:ls` |
| Vertical Split     |               | `:split-window -h`  | `:vs` |
| Horizontal Split   |               | `:split-window`     | `:sp` |

## vim

### Navigation

| Action                 | Binding       | Command                 |
| :--------------------- | :------------ | :---------------------- |
| Create Build Directory |               | `:Cmake`                |
| Select Target          | `<C-t>`       | `:FZFCMakeSelectTarget` |
| Build Target           | `<leader> b`  | `:CMakeBuild`           |

### git integration

| Action                 | Binding       | Command                 |
| :--------------------- | :------------ | :---------------------- |
| Run `git` Command      |               | `:Git`                  |
| Blame                  |               | `:Git blame`            |

### fzf integration

| Action                 | Binding       | Command                 |
| :--------------------- | :------------ | :---------------------- |
| Open File              | `<C-p>`       | `:Files`                |
| Open Recent File       | `<C-o>`       | `:History`              |
| Select Buffer          | `<C-b>`       | `:Buffers`              |
| Silver Searcher        | `<C-a>`       | `:Ag`                   |
| Select Target          | `<C-t>`       | `:FZFCMakeSelectTarget` |

### cmake integration

| Action                 | Binding       | Command                 |
| :--------------------- | :------------ | :---------------------- |
| Create Build Directory |               | `:Cmake`                |
| Select Target          | `<C-t>`       | `:FZFCMakeSelectTarget` |
| Build Target           | `<leader> b`  | `:CMakeBuild`           |
| Run Target             | `<f5>`        | `:CMakeRun`             |
| Remove CMake Cache     |               | `:CMakeReset`           |

### YouCompleteMe

| Action                 | Binding       | Command                         |
| :--------------------- | :------------ | :------------------------------ |
| Go to Include          | ti            | `:YcmCompleter GoToInclude`     |
| Go to Declaration      | tD            | `:YcmCompleter GoToDeclaration` |
| Go to Definition       | td            | `:YcmCompleter GoToDefinition`  |
| Go to Symbol           | ts            | `:YcmCompleter GoTo`            |
| Go to Reference        | tr            | `:YcmCompleter GoToReferences`  |
