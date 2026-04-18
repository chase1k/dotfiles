#!/usr/bin/env bash
# Install system packages
# Expects $PKG_MGR and $IS_WSL to be set (source detect_os.sh first)

set -e

APT_PACKAGES=(
    zsh tmux git curl wget
    zoxide
    ripgrep bat fd-find
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

install_neovim_apt() {
    # apt neovim is too old for AstroNvim (requires >=0.10.0) — install from GitHub releases
    local cur
    cur=$(nvim --version 2>/dev/null | awk 'NR==1{gsub(/v/,"",$2); print $2}')
    if [[ -z "$cur" ]] || ! printf '%s\n%s\n' "0.10.0" "$cur" | sort -V -C; then
        local tmp
        tmp=$(mktemp -d)
        curl -sL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
            | tar -C "$tmp" -xz
        install -Dm755 "$tmp"/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        cp -r "$tmp"/nvim-linux-x86_64/lib  /usr/local/
        cp -r "$tmp"/nvim-linux-x86_64/share /usr/local/
        rm -rf "$tmp"
        # tarball ships vi/vim symlinks — remove any that landed in /usr/local/bin
        for cmd in vi vim; do
            if [ -L "/usr/local/bin/$cmd" ] && readlink "/usr/local/bin/$cmd" | grep -q nvim; then
                rm -f "/usr/local/bin/$cmd"
            fi
        done
        # also clear alternatives if neovim somehow registered them
        update-alternatives --remove vi /usr/local/bin/nvim 2>/dev/null || true
        update-alternatives --remove vim /usr/local/bin/nvim 2>/dev/null || true
    fi
}

install_fastfetch_apt() {
    # fastfetch is not in standard Ubuntu repos — install via PPA
    if ! command -v fastfetch &>/dev/null; then
        if command -v add-apt-repository &>/dev/null; then
            add-apt-repository -y ppa:zhangsongcui3371/fastfetch
            apt-get update -q
            apt-get install -y fastfetch
        else
            echo "  [warn] add-apt-repository not available, skipping fastfetch install"
        fi
    fi
}

install_fzf_apt() {
    # apt fzf is too old to support --zsh (requires >=0.48.0) — install from GitHub
    if ! command -v fzf &>/dev/null; then
        local tmp arch tag
        tmp=$(mktemp -d)
        arch=$(uname -m); [ "$arch" = "x86_64" ] && arch="amd64" || arch="arm64"
        tag=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest \
            | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
        curl -sL "https://github.com/junegunn/fzf/releases/download/v${tag}/fzf-${tag}-linux_${arch}.tar.gz" \
            | tar -C "$tmp" -xz
        install -Dm755 "$tmp/fzf" /usr/local/bin/fzf
        rm -rf "$tmp"
    fi
}

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
        sudo bash -c "$(declare -f install_neovim_apt); install_neovim_apt" || true
        sudo bash -c "$(declare -f install_fastfetch_apt); install_fastfetch_apt" || true
        sudo bash -c "$(declare -f install_fzf_apt); install_fzf_apt" || true
        sudo bash -c "$(declare -f install_eza_apt); install_eza_apt" || true
        # bat is installed as batcat on Debian/Ubuntu — alias handled in shell
        ;;
    dnf)
        sudo dnf install -y "${DNF_PACKAGES[@]}"
        # eza available in EPEL or copr on Fedora
        if ! command -v eza &>/dev/null; then
            sudo dnf install -y eza 2>/dev/null || echo "  [warn] eza not available in repos, skipping"
        fi
        # neovim dnf package registers vi/vim alternatives — remove them so originals are preserved
        sudo update-alternatives --remove vi /usr/bin/nvim 2>/dev/null || true
        sudo update-alternatives --remove vim /usr/bin/nvim 2>/dev/null || true
        ;;
esac

echo "==> Packages installed."
