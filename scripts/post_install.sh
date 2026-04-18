#!/usr/bin/env bash
# Final setup: change default shell, print summary

ZSH_PATH="$(command -v zsh 2>/dev/null)"

if [ -z "$ZSH_PATH" ]; then
    echo "[warn] zsh not found in PATH — skipping chsh"
else
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        echo "==> Changing default shell to zsh ($ZSH_PATH)..."
        chsh -s "$ZSH_PATH"
    else
        echo "  [skip] Default shell is already zsh"
    fi
fi

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║        dotfiles install complete!            ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Start a new shell:  exec zsh                ║"
echo "║  Install tmux plugins: prefix + I            ║"
echo "║  Neovim plugins auto-install on first run    ║"
echo "╚══════════════════════════════════════════════╝"
