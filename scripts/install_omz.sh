#!/usr/bin/env bash
# Install Oh My Zsh, Powerlevel10k, and zsh plugins

set -e

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "==> Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "  [skip] Oh My Zsh already installed"
fi

echo "==> Installing Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "  [skip] powerlevel10k already present"
fi

echo "==> Installing zsh-autosuggestions..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "  [skip] zsh-autosuggestions already present"
fi

echo "==> Installing zsh-syntax-highlighting..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "  [skip] zsh-syntax-highlighting already present"
fi

echo "==> Installing fast-syntax-highlighting..."
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting \
        "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
else
    echo "  [skip] fast-syntax-highlighting already present"
fi

echo "==> Oh My Zsh + plugins ready."
