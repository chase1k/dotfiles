#!/usr/bin/env bash
# dotfiles install script
# Works on: Ubuntu / Debian / Pop!_OS / Fedora / WSL2
#
# Usage:
#   ./install.sh              # full install
#   ./install.sh --link-only  # symlinks only (skip package/tool install)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINK_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --link-only) LINK_ONLY=true ;;
        -h|--help)
            echo "Usage: $0 [--link-only]"
            exit 0
            ;;
    esac
done

echo ""
echo "  dotfiles — $(hostname)"
echo "  repo: $DOTFILES_DIR"
echo ""

# ── Phase 0: Detect OS ────────────────────────────────────────────────────────
echo "==> Detecting environment..."
source "$DOTFILES_DIR/scripts/detect_os.sh"

if $LINK_ONLY; then
    echo "==> --link-only: skipping package and tool install"
    source "$DOTFILES_DIR/scripts/link.sh"
    source "$DOTFILES_DIR/scripts/post_install.sh"
    exit 0
fi

# ── Phase 1: System packages ──────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/install_packages.sh"

# ── Phase 2: Oh My Zsh + plugins ─────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/install_omz.sh"

# ── Phase 3: Symlinks (before tools so tmux.conf is in place for TPM) ────────
source "$DOTFILES_DIR/scripts/link.sh"

# ── Phase 4: Dev tools (pwndbg, TPM, optional rustup/brew) ───────────────────
source "$DOTFILES_DIR/scripts/install_tools.sh"

# ── Phase 5: Finish ───────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/post_install.sh"
