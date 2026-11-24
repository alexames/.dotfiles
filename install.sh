#!/usr/bin/env bash
#
# Bootstrap a fresh machine from this dotfiles repo.
# Safe to re-run: every step is idempotent.
#
# Usage: ./install.sh [--skip-apt] [--skip-cargo] [--skip-luarocks]
#                     [--skip-vim] [--skip-stow] [--yes]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# ----- Flags -------------------------------------------------------------------

SKIP_APT=0
SKIP_CARGO=0
SKIP_LUAROCKS=0
SKIP_VIM=0
SKIP_STOW=0
ASSUME_YES=0

for arg in "$@"; do
    case "$arg" in
        --skip-apt)      SKIP_APT=1 ;;
        --skip-cargo)    SKIP_CARGO=1 ;;
        --skip-luarocks) SKIP_LUAROCKS=1 ;;
        --skip-vim)      SKIP_VIM=1 ;;
        --skip-stow)     SKIP_STOW=1 ;;
        -y|--yes)        ASSUME_YES=1 ;;
        -h|--help)
            sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "unknown flag: $arg" >&2; exit 2 ;;
    esac
done

# ----- Helpers -----------------------------------------------------------------

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
err()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; }

# Strip comments and blank lines from a package list. One package per line.
read_pkg_list() {
    local file="$1"
    [[ -r "$file" ]] || return 0
    sed -E 's/#.*$//; s/[[:space:]]+$//; s/^[[:space:]]+//' "$file" \
        | grep -v '^$' || true
}

confirm() {
    [[ $ASSUME_YES -eq 1 ]] && return 0
    local prompt="$1 [y/N] "
    local reply
    read -r -p "$prompt" reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

git_clone_or_pull() {
    local url="$1" dest="$2"
    if [[ -d "$dest/.git" ]]; then
        git -C "$dest" pull --ff-only --quiet
    else
        git clone --quiet "$url" "$dest"
    fi
}

# ----- SSH key -----------------------------------------------------------------

is_wsl() {
    grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

# Print the Windows user's home directory as a Linux path (e.g. /mnt/c/Users/me).
windows_home() {
    is_wsl && command -v cmd.exe >/dev/null 2>&1 || return 1
    local winpath
    # cd to a Windows drive first so cmd.exe doesn't warn about UNC paths.
    winpath=$(cd /mnt/c && cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')
    [[ -n "$winpath" && "$winpath" != *%* ]] || return 1
    wslpath -u "$winpath"
}

# On WSL, reuse the Windows user's SSH keys so both sides share one identity.
# Files are copied (not symlinked) because ssh refuses keys with the loose
# permissions that /mnt/c reports.
import_windows_ssh_keys() {
    local winhome src
    winhome=$(windows_home) || return 1
    src="$winhome/.ssh"
    compgen -G "$src/id_*.pub" >/dev/null || return 1

    log "Importing SSH keys from $src"
    install -d -m 700 "$HOME/.ssh"
    local f name
    for f in "$src"/id_*; do
        name=$(basename "$f")
        if [[ -e "$HOME/.ssh/$name" ]]; then
            continue
        elif [[ "$name" == *.pub ]]; then
            install -m 644 "$f" "$HOME/.ssh/$name"
        else
            install -m 600 "$f" "$HOME/.ssh/$name"
        fi
    done

    # Merge known_hosts so hosts trusted on Windows are trusted here too.
    if [[ -f "$src/known_hosts" ]]; then
        local merged
        merged=$(cat "$HOME/.ssh/known_hosts" "$src/known_hosts" 2>/dev/null \
                 | tr -d '\r' | awk 'NF && !seen[$0]++')
        printf '%s\n' "$merged" > "$HOME/.ssh/known_hosts"
        chmod 644 "$HOME/.ssh/known_hosts"
    fi
    [[ -f "$HOME/.ssh/id_ed25519" ]]
}

setup_ssh_key() {
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        return 0
    fi
    import_windows_ssh_keys && return 0
    log "Generating SSH key"
    ssh-keygen -t ed25519 -C 'Alexander.Ames@gmail.com' -q -N ""
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add "$HOME/.ssh/id_ed25519"
    echo
    cat "$HOME/.ssh/id_ed25519.pub"
    echo
    echo "Open https://github.com/settings/ssh/new and add the key above."
    read -r -n 1 -s -p "Press any key when done..."
    echo
}

# ----- apt ---------------------------------------------------------------------

install_apt() {
    [[ $SKIP_APT -eq 1 ]] && { log "Skipping apt"; return; }
    log "Installing apt packages"

    sudo add-apt-repository -y universe >/dev/null
    sudo add-apt-repository -y multiverse >/dev/null
    sudo apt-get update -qq

    # A single unknown package makes apt-get abort the whole install, and
    # package names drift between Ubuntu releases. Install what exists and
    # warn about the rest.
    local all=() available=() missing=()
    mapfile -t all < <(read_pkg_list apt.txt | sort -u)
    mapfile -t available < <(apt-cache policy "${all[@]}" 2>/dev/null | awk '
        /^[^ ]/                            { name = $0; sub(/:$/, "", name) }
        /^  Candidate:/ && $2 != "(none)"  { print name }' | sort -u)
    mapfile -t missing < <(comm -23 <(printf '%s\n' "${all[@]}") \
                                    <(printf '%s\n' "${available[@]}"))
    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "No install candidate (skipping): ${missing[*]}"
    fi

    sudo apt-get install -y --no-install-recommends "${available[@]}"
}

# ----- Rust / cargo ------------------------------------------------------------

install_rust() {
    [[ $SKIP_CARGO -eq 1 ]] && { log "Skipping cargo"; return; }

    if ! command -v cargo >/dev/null 2>&1 && [[ ! -x "$HOME/.cargo/bin/cargo" ]]; then
        log "Installing Rust toolchain"
        # --no-modify-path: bash/.bashrc already sources ~/.cargo/env, and
        # rustup's edits to ~/.bashrc/~/.profile would block stow.
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | sh -s -- -y --no-modify-path
    fi
    # shellcheck source=/dev/null
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

    local pkgs
    pkgs=$(read_pkg_list cargo.txt | xargs)
    if [[ -n "$pkgs" ]]; then
        log "Installing cargo packages: $pkgs"
        # shellcheck disable=SC2086
        cargo install $pkgs
    fi
}

# ----- luarocks ----------------------------------------------------------------

install_luarocks() {
    [[ $SKIP_LUAROCKS -eq 1 ]] && { log "Skipping luarocks"; return; }
    if ! command -v luarocks >/dev/null 2>&1; then
        warn "luarocks not on PATH — skipping lua packages"
        return
    fi

    log "Installing luarocks packages"
    local failures=()

    # Use a here-string instead of a pipe so the loop runs in the parent shell;
    # otherwise the failures array would be discarded when the subshell exits.
    while IFS= read -r rock; do
        printf '  %-20s' "$rock"
        local built=()
        for version in 5.1 5.2 5.3 5.4; do
            if luarocks --lua-version="$version" --local \
                        install "$rock" >/dev/null 2>&1; then
                built+=("$version")
            fi
        done
        if [[ ${#built[@]} -eq 0 ]]; then
            echo "FAILED"
            failures+=("$rock")
        else
            echo "${built[*]}"
        fi
    done < <(read_pkg_list luarocks.txt)

    if [[ ${#failures[@]} -gt 0 ]]; then
        warn "luarocks failures: ${failures[*]}"
    fi
}

# ----- vim from source ---------------------------------------------------------

install_vim() {
    [[ $SKIP_VIM -eq 1 ]] && { log "Skipping vim build"; return; }

    local src="$DOTFILES_DIR/vim/.vim/src/vim"
    git_clone_or_pull https://github.com/vim/vim "$src"

    # Skip rebuild if we already installed this exact commit. (Comparing
    # `vim --version` against the git tag never matched: one is "9.1", the
    # other "9.1.1234".) The stamp lives in vim/.vim/src/, which is gitignored.
    local stamp="$DOTFILES_DIR/vim/.vim/src/.installed-commit"
    local head
    head=$(git -C "$src" rev-parse HEAD)
    if [[ -x /usr/local/bin/vim && -f "$stamp" && "$(<"$stamp")" == "$head" ]]; then
        log "vim already built from ${head:0:12} — skipping rebuild"
        return
    fi

    log "Building vim from source"
    (
        cd "$src"
        ./configure                 \
            --with-features=huge    \
            --enable-python3interp  \
            --enable-luainterp      \
            --enable-cscope         \
            --quiet
        make -j"$(nproc)"
        sudo make install
    )
    echo "$head" > "$stamp"
}

# ----- vim tooling without an apt package --------------------------------------

# lua-language-server backs the Lua LSP client configured in the vimrc.
# Upstream only ships prebuilt tarballs, and the binary has to stay next to its
# bundled files, so unpack it under ~/.local/share and put a wrapper on PATH.
install_lua_ls() {
    [[ $SKIP_VIM -eq 1 ]] && return 0

    local arch
    case "$(uname -m)" in
        x86_64)  arch=x64 ;;
        aarch64) arch=arm64 ;;
        *) warn "No lua-language-server build for $(uname -m) — skipping"; return 0 ;;
    esac

    local dest="$HOME/.local/share/lua-language-server"
    local tag
    tag=$(curl -fsSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest \
          | sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p') || tag=""
    if [[ -z "$tag" ]]; then
        warn "Could not determine the latest lua-language-server release — skipping"
        return 0
    fi
    if [[ -x "$dest/bin/lua-language-server" \
          && "$(cat "$dest/.installed-version" 2>/dev/null)" == "$tag" ]]; then
        log "lua-language-server $tag already installed"
        return 0
    fi

    log "Installing lua-language-server $tag"
    local tmp
    tmp=$(mktemp -d)
    local url="https://github.com/LuaLS/lua-language-server/releases/download/$tag/lua-language-server-$tag-linux-$arch.tar.gz"
    if ! curl -fsSL "$url" | tar -xz -C "$tmp"; then
        warn "lua-language-server download failed — continuing without it"
        rm -rf "$tmp"
        return 0
    fi

    mkdir -p "$HOME/.local/share" "$HOME/.local/bin"
    rm -rf "$dest"
    mv "$tmp" "$dest"
    chmod 755 "$dest"
    echo "$tag" > "$dest/.installed-version"
    printf '#!/bin/sh\nexec "%s/bin/lua-language-server" "$@"\n' "$dest" \
        > "$HOME/.local/bin/lua-language-server"
    chmod +x "$HOME/.local/bin/lua-language-server"
}

# ----- Third-party config repos ------------------------------------------------

install_thirdparty() {
    log "Cloning third-party config repos"
    git_clone_or_pull https://github.com/junegunn/fzf "$DOTFILES_DIR/fzf/.fzf"
    # Binary only: shell integration lives in the tracked fzf/.fzf.bash. A full
    # install would generate ~/.fzf.bash itself, which then blocks stow.
    "$DOTFILES_DIR/fzf/.fzf/install" --bin

    git_clone_or_pull https://github.com/gpakosz/.tmux "$DOTFILES_DIR/tmux/.tmux"
}

# ----- starship (optional, no apt package) ------------------------------------

install_starship() {
    command -v starship >/dev/null 2>&1 && return 0
    confirm "Install starship prompt?" || return 0
    # Install into ~/.local/bin (already on PATH via .profile) so no sudo is
    # needed; the upstream installer can't prompt for sudo without a TTY.
    mkdir -p "$HOME/.local/bin"
    if ! curl -sS https://starship.rs/install.sh \
            | sh -s -- --yes --bin-dir "$HOME/.local/bin"; then
        warn "starship install failed — continuing without it"
    fi
}

# ----- stow --------------------------------------------------------------------

run_stow() {
    [[ $SKIP_STOW -eq 1 ]] && { log "Skipping stow"; return; }
    if ! command -v stow >/dev/null 2>&1; then
        warn "stow not installed — run \`sudo apt install stow\` then re-run with --skip-apt"
        return
    fi

    # Every top-level dir except .git and any with a stow-local-ignore opting out.
    local packages=()
    while IFS= read -r -d '' dir; do
        packages+=("$(basename "$dir")")
    done < <(find "$DOTFILES_DIR" -maxdepth 1 -mindepth 1 -type d \
                  ! -name '.git' ! -name '.github' -print0 | sort -z)

    # Pre-create parent dirs that multiple packages share. Without this, stow's
    # tree-folding would symlink the entire dir to the first package's copy,
    # then conflict when a second package tries to add to it.
    mkdir -p "$HOME/.config" "$HOME/.claude"

    log "Stowing: ${packages[*]}"

    # Dry-run first. A fresh machine ships its own ~/.bashrc and ~/.profile
    # (and tools like rustup or Claude Code write files too), which stow
    # refuses to overwrite. Move those aside into a timestamped backup instead
    # of aborting.
    local backup_dir
    backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    local target
    while IFS= read -r target; do
        [[ -e "$HOME/$target" || -L "$HOME/$target" ]] || continue
        mkdir -p "$backup_dir/$(dirname "$target")"
        mv "$HOME/$target" "$backup_dir/$target"
        warn "Moved existing ~/$target to $backup_dir/$target"
    done < <(stow -d "$DOTFILES_DIR" -t "$HOME" -n "${packages[@]}" 2>&1 | sed -nE \
        -e 's/.* over existing target (.+) since neither a link nor a directory.*/\1/p' \
        -e 's/.*existing target is (neither a link nor a directory|not owned by stow): (.+)$/\2/p')

    stow -d "$DOTFILES_DIR" -t "$HOME" -R "${packages[@]}"
}

# ----- main --------------------------------------------------------------------

main() {
    setup_ssh_key
    install_apt
    install_rust
    install_luarocks
    install_thirdparty
    install_starship
    install_vim
    install_lua_ls
    run_stow

    log "Done."
    cat <<'EOF'

Next steps:
  - Put per-host overrides in ~/.bashrc.local and ~/.gitconfig.local
  - Enable starship in your shell:  echo 'eval "$(starship init bash)"' >> ~/.bashrc.local
  - Authenticate gh:                gh auth login
  - For WSL: symlink ~/.dotfiles/wsl/.wslconfig to %USERPROFILE%\.wslconfig from PowerShell
  - Displaced pre-existing files (if any) are in ~/.dotfiles-backup/
EOF
}

main "$@"
