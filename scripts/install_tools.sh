#!/usr/bin/env bash
# Install development tools: pwndbg, TPM, optional rustup/homebrew

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── pwndbg ────────────────────────────────────────────────────────────────────
echo "==> Installing pwndbg..."
if [ ! -d "$HOME/tools/pwndbg" ]; then
    mkdir -p "$HOME/tools"
    git clone https://github.com/pwndbg/pwndbg.git "$HOME/tools/pwndbg"
    cd "$HOME/tools/pwndbg"
    ./setup.sh
    cd "$DOTFILES_DIR"
else
    echo "  [skip] pwndbg already present at ~/tools/pwndbg"
fi

# ── TPM (Tmux Plugin Manager) ─────────────────────────────────────────────────
echo "==> Installing TPM..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "  [skip] TPM already present"
fi

# Install tmux plugins headlessly (requires ~/.tmux.conf to be symlinked first)
if [ -f "$HOME/.tmux.conf" ] && command -v tmux &>/dev/null; then
    echo "  Installing tmux plugins..."
    tmux new-session -d -s _dotfiles_install 2>/dev/null || true
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
    tmux kill-session -t _dotfiles_install 2>/dev/null || true
fi

# ── Rust / cargo (optional) ───────────────────────────────────────────────────
if ! command -v cargo &>/dev/null; then
    echo ""
    read -rp "Install Rust (rustup)? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
else
    echo "  [skip] cargo already installed"
fi

# ── Homebrew (optional) ───────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo ""
    read -rp "Install Homebrew (Linux)? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
else
    echo "  [skip] brew already installed"
fi

echo "==> Tools ready."
