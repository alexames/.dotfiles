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

setup_ssh_key() {
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        return 0
    fi
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

    # shellcheck disable=SC2046
    sudo apt-get install -y --no-install-recommends \
        $(read_pkg_list apt.txt | xargs)
}

# ----- Rust / cargo ------------------------------------------------------------

install_rust() {
    [[ $SKIP_CARGO -eq 1 ]] && { log "Skipping cargo"; return; }

    if ! command -v cargo >/dev/null 2>&1; then
        log "Installing Rust toolchain"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
    fi

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

    # Skip rebuild if the local source is at the same commit as the installed binary.
    local installed_ver=""
    if command -v vim >/dev/null 2>&1; then
        installed_ver=$(vim --version | head -1 | awk '{print $5}')
    fi
    local src_ver
    src_ver=$(git -C "$src" describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "")

    if [[ -n "$installed_ver" && -n "$src_ver" && "$installed_ver" == "$src_ver" ]]; then
        log "vim $installed_ver already current — skipping rebuild (use --skip-vim to silence)"
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
}

# ----- Third-party config repos ------------------------------------------------

install_thirdparty() {
    log "Cloning third-party config repos"
    git_clone_or_pull https://github.com/junegunn/fzf "$DOTFILES_DIR/fzf/.fzf"
    "$DOTFILES_DIR/fzf/.fzf/install" --key-bindings --completion --no-update-rc

    git_clone_or_pull https://github.com/gpakosz/.tmux "$DOTFILES_DIR/tmux/.tmux"
}

# ----- starship (optional, no apt package) ------------------------------------

install_starship() {
    command -v starship >/dev/null 2>&1 && return 0
    confirm "Install starship prompt?" || return 0
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
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

    # Dry-run first so we surface conflicts cleanly instead of half-applying.
    if ! stow -d "$DOTFILES_DIR" -t "$HOME" -nv "${packages[@]}" 2>&1 \
            | grep -E '(conflict|existing target)' >&2; then
        : # no conflicts surfaced
    fi

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
    run_stow

    log "Done."
    cat <<'EOF'

Next steps:
  - Put per-host overrides in ~/.bashrc.local and ~/.gitconfig.local
  - Enable starship in your shell:  echo 'eval "$(starship init bash)"' >> ~/.bashrc.local
  - Authenticate gh:                gh auth login
  - For WSL: symlink ~/.dotfiles/wsl/.wslconfig to %USERPROFILE%\.wslconfig from PowerShell
EOF
}

main "$@"
