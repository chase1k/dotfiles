#!/usr/bin/env bash
# Install system packages
# Expects $PKG_MGR and $IS_WSL to be set (source detect_os.sh first)

set -e

APT_PACKAGES=(
    zsh tmux git curl wget
    neovim fzf zoxide
    ripgrep bat fd-find
    fastfetch
    python3-pip python3-venv
    build-essential
    xclip  # x11 clipboard fallback
)

DNF_PACKAGES=(
    zsh tmux git curl wget
    neovim fzf zoxide
    ripgrep bat fd-find
    fastfetch
    python3-pip
    gcc make
    xclip
)

install_eza_apt() {
    # eza is not in standard Ubuntu repos — use the official apt repo
    if ! command -v eza &>/dev/null; then
        if command -v gpg &>/dev/null; then
            mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
                | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
                | tee /etc/apt/sources.list.d/gierens.list
            chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            apt-get update -q
            apt-get install -y eza
        else
            echo "  [warn] gpg not available, skipping eza install"
        fi
    fi
}

echo "==> Installing packages via $PKG_MGR..."

case "$PKG_MGR" in
    apt)
        sudo apt-get update -q
        sudo apt-get install -y "${APT_PACKAGES[@]}"
        sudo install_eza_apt || true
        # bat is installed as batcat on Debian/Ubuntu — alias handled in shell
        ;;
    dnf)
        sudo dnf install -y "${DNF_PACKAGES[@]}"
        # eza available in EPEL or copr on Fedora
        if ! command -v eza &>/dev/null; then
            sudo dnf install -y eza 2>/dev/null || echo "  [warn] eza not available in repos, skipping"
        fi
        ;;
esac

echo "==> Packages installed."
